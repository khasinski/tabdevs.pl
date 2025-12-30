class Comment < ApplicationRecord
  belongs_to :post, counter_cache: true
  belongs_to :parent, class_name: "Comment", optional: true
  belongs_to :author, class_name: "User"
  has_many :replies, class_name: "Comment", foreign_key: :parent_id, dependent: :destroy
  has_many :votes, as: :votable, dependent: :destroy
  has_many :moderation_items, as: :moderatable, dependent: :destroy
  has_many :notifications, as: :notifiable, dependent: :destroy

  enum :status, { active: 0, hidden: 1, removed: 2 }

  validates :body, presence: true, length: { in: 1..5000 }
  validate :max_nesting_depth

  scope :visible, -> { where(status: :active) }
  scope :top_level, -> { where(parent_id: nil) }
  scope :ordered, -> { order(created_at: :asc) }
  scope :recent, -> { order(created_at: :desc) }

  after_create :create_notification
  after_update :update_post_comments_count, if: :saved_change_to_status?

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

  def depth
    return 0 if parent.nil?
    parent.depth + 1
  end

  def can_reply?
    depth < 2  # Max 3 levels: 0, 1, 2
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

  def max_nesting_depth
    if parent.present? && !parent.can_reply?
      errors.add(:parent, I18n.t("activerecord.errors.models.comment.attributes.parent.max_nesting"))
    end
  end

  def update_post_comments_count
    post.update_comments_count!
  end

  def create_notification
    # Notify post author if this is a direct comment on the post
    if parent.nil? && post.author != author
      Notification.create!(
        user: post.author,
        notification_type: :post_comment,
        notifiable: self,
        actor: author
      )
    # Notify parent comment author if this is a reply to a comment
    elsif parent.present? && parent.author != author
      Notification.create!(
        user: parent.author,
        notification_type: :comment_reply,
        notifiable: self,
        actor: author
      )
    end
  end
end
