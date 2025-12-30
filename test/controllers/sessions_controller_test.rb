require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "shows login page" do
    get login_path
    assert_response :success
    assert_includes response.body, I18n.t("views.auth.login_title")
  end

  test "redirects logged in users from login page" do
    user = create(:user)
    magic_link = user.magic_links.create!(token: SecureRandom.urlsafe_base64(32), expires_at: 1.hour.from_now)
    get auth_callback_path(token: magic_link.token)

    get login_path
    assert_redirected_to root_path
  end

  test "sends magic link email for valid email" do
    assert_difference "MagicLink.count", 1 do
      post login_path, params: { email: "new@example.com" }
    end
    assert_redirected_to auth_sent_path
    assert_match I18n.t("flash.auth.magic_link_sent", email: "new@example.com"), flash[:notice]
  end

  test "creates new user if email not found" do
    assert_difference "User.count", 1 do
      post login_path, params: { email: "newuser@example.com" }
    end
    assert User.find_by(email: "newuser@example.com").present?
  end

  test "rejects invalid email" do
    post login_path, params: { email: "not-an-email" }
    assert_response :unprocessable_entity
  end

  test "rejects empty email" do
    post login_path, params: { email: "" }
    assert_response :unprocessable_entity
  end

  test "logs in user with valid magic link" do
    user = create(:user)
    magic_link = user.magic_links.create!(token: SecureRandom.urlsafe_base64(32), expires_at: 1.hour.from_now)

    get auth_callback_path(token: magic_link.token)
    assert_redirected_to root_path
    assert_equal I18n.t("flash.auth.login_success"), flash[:notice]

    # Verify user is logged in
    get root_path
    assert_match user.username, response.body
  end

  test "rejects expired magic link" do
    user = create(:user)
    magic_link = user.magic_links.create!(token: SecureRandom.urlsafe_base64(32), expires_at: 1.hour.ago)

    get auth_callback_path(token: magic_link.token)
    assert_redirected_to login_path
    assert_equal I18n.t("flash.auth.invalid_token"), flash[:alert]
  end

  test "rejects invalid magic link token" do
    get auth_callback_path(token: "invalid-token")
    assert_redirected_to login_path
  end

  test "logs out user" do
    user = create(:user)
    magic_link = user.magic_links.create!(token: SecureRandom.urlsafe_base64(32), expires_at: 1.hour.from_now)
    get auth_callback_path(token: magic_link.token)

    delete logout_path
    assert_redirected_to root_path
    assert_equal I18n.t("flash.auth.logout_success"), flash[:notice]
  end
end
