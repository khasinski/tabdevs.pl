class Post < ApplicationRecord
  include Editable
  include Votable

  belongs_to :author, class_name: "User"
  has_many :comments, dependent: :destroy
  has_many :moderation_items, as: :moderatable, dependent: :destroy
  has_many :notifications, as: :notifiable, dependent: :destroy
  has_many :bookmarks, dependent: :destroy
  has_many :flags, as: :flaggable, dependent: :destroy

  enum :post_type, { link: 0, text: 1 }
  enum :tag, { ask: 0, show: 1, case_study: 2, news: 3 }, prefix: true
  enum :status, { active: 0, hidden: 1, removed: 2 }

  validates :title, presence: true, length: { in: 3..120 }
  validates :body, length: { maximum: 10000 }
  validates :url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true }
  validate :body_required_for_text_posts

  before_validation :set_post_type
  before_save :normalize_url
  before_save :set_normalized_url
  after_create_commit :ping_search_engines

  scope :visible, -> { where(status: :active) }
  scope :by_new, -> { visible.order(created_at: :desc) }
  scope :by_top, -> { visible.order(Arel.sql("score / POWER(EXTRACT(EPOCH FROM (NOW() - created_at)) / 3600 + 2, 1.5) DESC")) }
  scope :recent, -> { order(created_at: :desc) }

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

  def body_required_for_text_posts
    if url.blank? && body.blank?
      errors.add(:body, I18n.t("activerecord.errors.models.post.attributes.body.required_without_url"))
    end
  end

  def ping_search_engines
    PingSearchEnginesJob.perform_later(id) unless by_bot?
  end
end
