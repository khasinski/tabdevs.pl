class NewsletterMailer < ApplicationMailer
  def confirmation(subscription)
    @subscription = subscription
    @confirm_url = newsletter_confirm_url(token: subscription.token)

    mail(
      to: subscription.email,
      subject: t("mailers.newsletter.confirmation.subject")
    )
  end

  def weekly_digest(subscription, posts)
    @subscription = subscription
    @posts = posts
    @unsubscribe_url = newsletter_unsubscribe_url(token: subscription.token)

    mail(
      to: subscription.email,
      subject: t("mailers.newsletter.weekly_digest.subject", date: I18n.l(Date.current, format: :long))
    )
  end
end
