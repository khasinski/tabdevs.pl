class NewsletterSubscriptionService
  Result = Struct.new(:success, :message_key, keyword_init: true)

  def initialize(email, auto_confirm: false)
    @email = email.to_s.downcase.strip
    @auto_confirm = auto_confirm
  end

  def subscribe
    return Result.new(success: false, message_key: :invalid_email) if invalid_email?

    subscription = NewsletterSubscription.find_by(email: @email)

    if subscription
      handle_existing_subscription(subscription)
    else
      create_new_subscription
    end
  end

  def unsubscribe
    subscription = NewsletterSubscription.find_by(email: @email)

    if subscription&.confirmed? && !subscription.unsubscribed?
      subscription.unsubscribe!
      Result.new(success: true, message_key: :unsubscribed)
    else
      Result.new(success: false, message_key: :not_subscribed)
    end
  end

  private

  def invalid_email?
    @email.blank? || !@email.match?(URI::MailTo::EMAIL_REGEXP)
  end

  def handle_existing_subscription(subscription)
    if subscription.unsubscribed?
      subscription.resubscribe!
      Result.new(success: true, message_key: :resubscribed)
    elsif subscription.confirmed?
      Result.new(success: true, message_key: :already_subscribed)
    else
      NewsletterMailer.confirmation(subscription).deliver_later
      Result.new(success: true, message_key: :confirmation_resent)
    end
  end

  def create_new_subscription
    subscription = NewsletterSubscription.create!(email: @email)

    if @auto_confirm
      subscription.confirm!
      Result.new(success: true, message_key: :subscribed)
    else
      NewsletterMailer.confirmation(subscription).deliver_later
      Result.new(success: true, message_key: :subscribed_pending)
    end
  end
end
