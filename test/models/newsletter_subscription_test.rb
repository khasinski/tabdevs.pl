require "test_helper"

class NewsletterSubscriptionTest < ActiveSupport::TestCase
  test "valid newsletter subscription" do
    subscription = build(:newsletter_subscription)
    assert subscription.valid?
  end

  test "requires email" do
    subscription = build(:newsletter_subscription, email: nil)
    assert_not subscription.valid?
  end

  test "validates email format" do
    subscription = build(:newsletter_subscription, email: "invalid-email")
    assert_not subscription.valid?
  end

  test "validates email uniqueness case insensitively" do
    create(:newsletter_subscription, email: "test@example.com")
    duplicate = build(:newsletter_subscription, email: "TEST@EXAMPLE.COM")
    assert_not duplicate.valid?
  end

  test "generates token on create" do
    subscription = create(:newsletter_subscription, token: nil)
    assert_not_nil subscription.token
    assert subscription.token.length > 20
  end

  test "confirmed? returns false for unconfirmed subscription" do
    subscription = build(:newsletter_subscription, confirmed_at: nil)
    assert_not subscription.confirmed?
  end

  test "confirmed? returns true for confirmed subscription" do
    subscription = build(:newsletter_subscription, :confirmed)
    assert subscription.confirmed?
  end

  test "unsubscribed? returns false when not unsubscribed" do
    subscription = build(:newsletter_subscription, unsubscribed_at: nil)
    assert_not subscription.unsubscribed?
  end

  test "unsubscribed? returns true when unsubscribed" do
    subscription = build(:newsletter_subscription, :unsubscribed)
    assert subscription.unsubscribed?
  end

  test "confirm! sets confirmed_at" do
    subscription = create(:newsletter_subscription)
    assert_nil subscription.confirmed_at

    subscription.confirm!

    assert_not_nil subscription.confirmed_at
    assert subscription.confirmed?
  end

  test "confirm! does not update already confirmed subscription" do
    original_time = 1.week.ago
    subscription = create(:newsletter_subscription, confirmed_at: original_time)

    subscription.confirm!

    assert_in_delta original_time.to_i, subscription.confirmed_at.to_i, 1
  end

  test "unsubscribe! sets unsubscribed_at" do
    subscription = create(:newsletter_subscription, :confirmed)

    subscription.unsubscribe!

    assert_not_nil subscription.unsubscribed_at
    assert subscription.unsubscribed?
  end

  test "resubscribe! clears unsubscribed_at and sets confirmed_at" do
    subscription = create(:newsletter_subscription, :unsubscribed)

    subscription.resubscribe!

    assert_nil subscription.unsubscribed_at
    assert subscription.confirmed?
  end

  test "confirmed scope returns only confirmed subscriptions" do
    unconfirmed = create(:newsletter_subscription)
    confirmed = create(:newsletter_subscription, :confirmed)

    results = NewsletterSubscription.confirmed

    assert_not_includes results, unconfirmed
    assert_includes results, confirmed
  end

  test "active scope returns confirmed and not unsubscribed" do
    unconfirmed = create(:newsletter_subscription)
    confirmed = create(:newsletter_subscription, :confirmed)
    unsubscribed = create(:newsletter_subscription, :unsubscribed)

    results = NewsletterSubscription.active

    assert_not_includes results, unconfirmed
    assert_includes results, confirmed
    assert_not_includes results, unsubscribed
  end
end
