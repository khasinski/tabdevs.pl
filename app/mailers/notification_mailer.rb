class NotificationMailer < ApplicationMailer
  def comment_reply(notification)
    @notification = notification
    @user = notification.user
    @comment = notification.notifiable
    @post = @comment.post
    @actor = notification.actor

    mail(
      to: @user.email,
      subject: t("mailers.notification.comment_reply.subject", username: @actor.username)
    )
  end

  def post_comment(notification)
    @notification = notification
    @user = notification.user
    @comment = notification.notifiable
    @post = @comment.post
    @actor = notification.actor

    mail(
      to: @user.email,
      subject: t("mailers.notification.post_comment.subject", title: truncate(@post.title, length: 50))
    )
  end

  def mention(notification)
    @notification = notification
    @user = notification.user
    @comment = notification.notifiable
    @post = @comment.post
    @actor = notification.actor

    mail(
      to: @user.email,
      subject: t("mailers.notification.mention.subject", username: @actor.username)
    )
  end

  private

  def truncate(text, length:)
    text.length > length ? "#{text[0...length]}..." : text
  end
end
