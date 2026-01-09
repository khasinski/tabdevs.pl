class NewsletterController < ApplicationController
  def create
    email = params[:email].to_s.downcase.strip

    if email.blank? || !email.match?(URI::MailTo::EMAIL_REGEXP)
      return redirect_back fallback_location: root_path, alert: t("flash.newsletter.invalid_email")
    end

    subscription = NewsletterSubscription.find_by(email: email)

    if subscription
      if subscription.unsubscribed?
        subscription.resubscribe!
        redirect_back fallback_location: root_path, notice: t("flash.newsletter.resubscribed")
      elsif subscription.confirmed?
        redirect_back fallback_location: root_path, notice: t("flash.newsletter.already_subscribed")
      else
        NewsletterMailer.confirmation(subscription).deliver_later
        redirect_back fallback_location: root_path, notice: t("flash.newsletter.confirmation_resent")
      end
    else
      subscription = NewsletterSubscription.create!(email: email)
      NewsletterMailer.confirmation(subscription).deliver_later
      redirect_back fallback_location: root_path, notice: t("flash.newsletter.subscribed")
    end
  end

  def confirm
    subscription = NewsletterSubscription.find_by(token: params[:token])

    if subscription
      subscription.confirm!
      redirect_to root_path, notice: t("flash.newsletter.confirmed")
    else
      redirect_to root_path, alert: t("flash.newsletter.invalid_token")
    end
  end

  def unsubscribe
    subscription = NewsletterSubscription.find_by(token: params[:token])

    if subscription
      subscription.unsubscribe!
      redirect_to root_path, notice: t("flash.newsletter.unsubscribed")
    else
      redirect_to root_path, alert: t("flash.newsletter.invalid_token")
    end
  end
end
