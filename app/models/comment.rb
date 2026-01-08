class Comment < ApplicationRecord
  include Editable
  include Votable

  belongs_to :post, counter_cache: true
  belongs_to :parent, class_name: "Comment", optional: true
  belongs_to :author, class_name: "User"
  has_many :replies, class_name: "Comment", foreign_key: :parent_id, dependent: :destroy
  has_many :moderation_items, as: :moderatable, dependent: :destroy
  has_many :notifications, as: :notifiable, dependent: :destroy
  has_many :flags, as: :flaggable, dependent: :destroy

  enum :status, { active: 0, hidden: 1, removed: 2 }

  validates :body, presence: true, length: { in: 1..5000 }
  validate :max_nesting_depth

  scope :visible, -> { where(status: :active) }
  scope :top_level, -> { where(parent_id: nil) }
  scope :ordered, -> { order(created_at: :asc) }
  scope :recent, -> { order(created_at: :desc) }

  after_create :create_notification
  after_update :update_post_comments_count, if: :saved_change_to_status?

  def depth
    return 0 if parent.nil?
    parent.depth + 1
  end

  def can_reply?
    depth < 4  # Max 5 levels: 0, 1, 2, 3, 4
  end

  def reply_parent_id
    # At max depth, replies go to same level (sibling) instead of nested
    depth >= 4 ? parent_id : id
  end

  private

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
      notification = Notification.create!(
        user: post.author,
        notification_type: :post_comment,
        notifiable: self,
        actor: author
      )
      send_notification_email(notification)
    # Notify parent comment author if this is a reply to a comment
    elsif parent.present? && parent.author != author
      notification = Notification.create!(
        user: parent.author,
        notification_type: :comment_reply,
        notifiable: self,
        actor: author
      )
      send_notification_email(notification)
    end

    # Handle @mentions
    create_mention_notifications
  end

  def create_mention_notifications
    mentioned_usernames = body.scan(/@([a-zA-Z0-9_-]+)/).flatten.uniq
    return if mentioned_usernames.empty?

    mentioned_users = User.where(username: mentioned_usernames)
    already_notified = [ author.id ]
    already_notified << post.author.id if parent.nil?
    already_notified << parent.author.id if parent.present?

    mentioned_users.each do |user|
      next if already_notified.include?(user.id)
      already_notified << user.id

      notification = Notification.create!(
        user: user,
        notification_type: :mention,
        notifiable: self,
        actor: author
      )
      send_notification_email(notification)
    end
  end

  def send_notification_email(notification)
    return unless notification.user.email_notifications?

    case notification.notification_type
    when "comment_reply"
      NotificationMailer.comment_reply(notification).deliver_later
    when "post_comment"
      NotificationMailer.post_comment(notification).deliver_later
    when "mention"
      NotificationMailer.mention(notification).deliver_later
    end
  end
end
