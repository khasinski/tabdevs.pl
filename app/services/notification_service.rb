class NotificationService
  def self.notify_on_comment(comment)
    new(comment).notify_on_comment
  end

  def self.notify_on_mention(mentioner:, mentioned_user:, content:)
    new(nil).notify_on_mention(mentioner, mentioned_user, content)
  end

  def initialize(notifiable)
    @notifiable = notifiable
  end

  def notify_on_comment
    return unless @notifiable.is_a?(Comment)
    comment = @notifiable

    # Don't notify yourself
    return if comment.parent.nil? && comment.post.author == comment.author
    return if comment.parent.present? && comment.parent.author == comment.author

    if comment.parent.nil?
      # Notify post author about new comment
      create_notification(
        user: comment.post.author,
        notification_type: :post_comment,
        actor: comment.author
      )
    else
      # Notify parent comment author about reply
      create_notification(
        user: comment.parent.author,
        notification_type: :comment_reply,
        actor: comment.author
      )
    end
  end

  def notify_on_mention(mentioner, mentioned_user, content)
    return if mentioner == mentioned_user

    create_notification(
      user: mentioned_user,
      notification_type: :mention,
      notifiable: content,
      actor: mentioner
    )
  end

  private

  def create_notification(user:, notification_type:, notifiable: nil, actor: nil)
    Notification.create!(
      user: user,
      notification_type: notification_type,
      notifiable: notifiable || @notifiable,
      actor: actor
    )
  end
end
