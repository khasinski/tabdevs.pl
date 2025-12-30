class Post < ApplicationRecord
  belongs_to :author, class_name: "User"
  has_many :comments, dependent: :destroy
  has_many :votes, as: :votable, dependent: :destroy
  has_many :moderation_items, as: :moderatable, dependent: :destroy
  has_many :notifications, as: :notifiable, dependent: :destroy

  enum :post_type, { link: 0, text: 1 }
  enum :tag, { ask: 0, show: 1, case_study: 2, news: 3 }, prefix: true
  enum :status, { active: 0, hidden: 1, removed: 2 }

  validates :title, presence: true, length: { in: 3..120 }
  validates :body, length: { maximum: 10000 }
  validates :url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true }
  validate :url_or_body_present
  validate :url_required_for_link_type

  before_validation :set_post_type
  before_save :normalize_url
  before_save :set_normalized_url

  scope :visible, -> { where(status: :active) }
  scope :by_new, -> { visible.order(created_at: :desc) }
  scope :by_top, -> { visible.order(Arel.sql("score / POWER(EXTRACT(EPOCH FROM (NOW() - created_at)) / 3600 + 2, 1.5) DESC")) }
  scope :recent, -> { order(created_at: :desc) }

  def editable?
    created_at > SiteSetting.get(:edit_grace_period_minutes, 15).to_i.minutes.ago
  end

  def can_be_edited_by?(user)
    return false unless user
    return true if user.admin? || user.moderator?
    author == user && editable?
  end

  def edited?
    edited_at.present?
  end

  def mark_as_edited!
    update_column(:edited_at, Time.current) unless edited?
  end

  def domain
    return nil unless url.present?
    URI.parse(url).host&.sub(/\Awww\./, "")
  rescue URI::InvalidURIError
    nil
  end

  # comments_count is now a counter_cache column
  # Only count visible comments when counter needs manual update
  def visible_comments_count
    comments.visible.count
  end

  def update_comments_count!
    update_column(:comments_count, visible_comments_count)
  end

  def upvote!(user)
    vote_with_value!(user, 1)
  end

  def downvote!(user)
    return false unless user.can_downvote?
    vote_with_value!(user, -1)
  end

  def remove_vote!(user)
    vote = votes.find_by(user: user)
    return false unless vote

    transaction do
      decrement!(:score, vote.value)
      vote.destroy!
    end
    true
  end

  def user_vote(user)
    votes.find_by(user: user)&.value
  end

  def self.find_duplicate(url)
    return nil if url.blank?

    normalized = normalize_url_for_comparison(url)
    days = SiteSetting.get(:duplicate_url_days, 365).to_i

    # Use indexed normalized_url column for fast lookup
    visible
      .where("created_at > ?", days.days.ago)
      .where("score >= 5")
      .where(normalized_url: normalized)
      .first
  end

  def self.normalize_url_for_comparison(url)
    url.to_s.downcase
       .sub(%r{^https?://(www\.)?}, "")
       .sub(%r{/$}, "")
  end

  def by_bot?
    author.bot?
  end

  private

  def vote_with_value!(user, value)
    existing = votes.find_by(user: user)

    transaction do
      if existing
        decrement!(:score, existing.value)
        existing.update!(value: value)
      else
        votes.create!(user: user, value: value)
      end
      increment!(:score, value)
    end
    true
  end

  def set_post_type
    if url.present?
      self.post_type = :link
    elsif body.present?
      self.post_type = :text
    end
  end

  def normalize_url
    return if url.blank?
    self.url = url.strip
    self.url = "https://#{url}" unless url.match?(%r{^https?://})
  end

  def set_normalized_url
    self.normalized_url = url.present? ? self.class.normalize_url_for_comparison(url) : nil
  end

  def url_or_body_present
    if url.blank? && body.blank?
      errors.add(:base, I18n.t("activerecord.errors.models.post.attributes.base.url_or_body_required"))
    end
  end

  def url_required_for_link_type
    if link? && url.blank?
      errors.add(:url, I18n.t("activerecord.errors.models.post.attributes.url.required_for_link"))
    end
  end
end
