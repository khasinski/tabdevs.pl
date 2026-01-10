class NewsletterController < ApplicationController
  def create
    result = NewsletterSubscriptionService.new(params[:email]).subscribe

    if result.success
      redirect_back fallback_location: root_path, notice: t("flash.newsletter.#{result.message_key}")
    else
      redirect_back fallback_location: root_path, alert: t("flash.newsletter.#{result.message_key}")
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
