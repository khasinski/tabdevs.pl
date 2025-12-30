class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :notifiable, polymorphic: true

  enum :notification_type, { comment_reply: 0, post_comment: 1, mention: 2 }
  belongs_to :actor, class_name: "User", optional: true

  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  def read?
    read_at.present?
  end

  def mark_as_read!
    update!(read_at: Time.current) unless read?
  end

  def self.mark_all_as_read!(user)
    user.notifications.unread.update_all(read_at: Time.current)
  end
end
