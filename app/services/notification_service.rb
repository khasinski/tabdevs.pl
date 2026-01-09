class NotificationService
  def self.notify_on_comment(comment)
    new(comment).notify_on_comment
  end

  def initialize(comment)
    @comment = comment
  end

  def notify_on_comment
    notify_post_or_parent_author
    notify_mentioned_users
  end

  private

  def notify_post_or_parent_author
    if @comment.parent.nil?
      notify_post_author
    else
      notify_parent_author
    end
  end

  def notify_post_author
    return if @comment.post.author == @comment.author

    notification = create_notification(
      user: @comment.post.author,
      notification_type: :post_comment
    )
    send_email(notification)
  end

  def notify_parent_author
    return if @comment.parent.author == @comment.author

    notification = create_notification(
      user: @comment.parent.author,
      notification_type: :comment_reply
    )
    send_email(notification)
  end

  def notify_mentioned_users
    mentioned_usernames = @comment.body.scan(/@([a-zA-Z0-9_-]+)/).flatten.uniq
    return if mentioned_usernames.empty?

    already_notified = build_already_notified_list
    mentioned_users = User.where(username: mentioned_usernames)

    mentioned_users.each do |user|
      next if already_notified.include?(user.id)
      already_notified << user.id

      notification = create_notification(
        user: user,
        notification_type: :mention
      )
      send_email(notification)
    end
  end

  def build_already_notified_list
    list = [@comment.author.id]
    list << @comment.post.author.id if @comment.parent.nil?
    list << @comment.parent.author.id if @comment.parent.present?
    list
  end

  def create_notification(user:, notification_type:)
    Notification.create!(
      user: user,
      notification_type: notification_type,
      notifiable: @comment,
      actor: @comment.author
    )
  end

  def send_email(notification)
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
