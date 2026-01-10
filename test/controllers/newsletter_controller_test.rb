require "test_helper"

class NewsletterControllerTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  test "creates new subscription with valid email" do
    assert_difference "NewsletterSubscription.count", 1 do
      post newsletter_path, params: { email: "new@example.com" }
    end

    subscription = NewsletterSubscription.last
    assert_equal "new@example.com", subscription.email
    assert_not subscription.confirmed?
    assert_redirected_to root_path
    assert_equal I18n.t("flash.newsletter.subscribed"), flash[:notice]
  end

  test "sends confirmation email" do
    assert_enqueued_emails 1 do
      post newsletter_path, params: { email: "new@example.com" }
    end
  end

  test "rejects invalid email" do
    assert_no_difference "NewsletterSubscription.count" do
      post newsletter_path, params: { email: "invalid" }
    end

    assert_redirected_to root_path
    assert_equal I18n.t("flash.newsletter.invalid_email"), flash[:alert]
  end

  test "rejects empty email" do
    assert_no_difference "NewsletterSubscription.count" do
      post newsletter_path, params: { email: "" }
    end

    assert_redirected_to root_path
    assert_equal I18n.t("flash.newsletter.invalid_email"), flash[:alert]
  end

  test "handles already subscribed email" do
    create(:newsletter_subscription, :confirmed, email: "existing@example.com")

    assert_no_difference "NewsletterSubscription.count" do
      post newsletter_path, params: { email: "existing@example.com" }
    end

    assert_redirected_to root_path
    assert_equal I18n.t("flash.newsletter.already_subscribed"), flash[:notice]
  end

  test "resends confirmation for unconfirmed subscription" do
    create(:newsletter_subscription, email: "unconfirmed@example.com")

    assert_enqueued_emails 1 do
      post newsletter_path, params: { email: "unconfirmed@example.com" }
    end

    assert_redirected_to root_path
    assert_equal I18n.t("flash.newsletter.confirmation_resent"), flash[:notice]
  end

  test "resubscribes unsubscribed user" do
    subscription = create(:newsletter_subscription, :unsubscribed, email: "unsub@example.com")

    post newsletter_path, params: { email: "unsub@example.com" }

    subscription.reload
    assert subscription.confirmed?
    assert_not subscription.unsubscribed?
    assert_redirected_to root_path
    assert_equal I18n.t("flash.newsletter.resubscribed"), flash[:notice]
  end

  test "confirms subscription with valid token" do
    subscription = create(:newsletter_subscription)

    get newsletter_confirm_path(token: subscription.token)

    subscription.reload
    assert subscription.confirmed?
    assert_redirected_to root_path
    assert_equal I18n.t("flash.newsletter.confirmed"), flash[:notice]
  end

  test "rejects confirmation with invalid token" do
    get newsletter_confirm_path(token: "invalid-token")

    assert_redirected_to root_path
    assert_equal I18n.t("flash.newsletter.invalid_token"), flash[:alert]
  end

  test "unsubscribes with valid token" do
    subscription = create(:newsletter_subscription, :confirmed)

    get newsletter_unsubscribe_path(token: subscription.token)

    subscription.reload
    assert subscription.unsubscribed?
    assert_redirected_to root_path
    assert_equal I18n.t("flash.newsletter.unsubscribed"), flash[:notice]
  end

  test "rejects unsubscribe with invalid token" do
    get newsletter_unsubscribe_path(token: "invalid-token")

    assert_redirected_to root_path
    assert_equal I18n.t("flash.newsletter.invalid_token"), flash[:alert]
  end
end
