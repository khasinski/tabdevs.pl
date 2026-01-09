require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get faq" do
    get faq_path
    assert_response :success
  end

  test "should get terms" do
    get terms_path
    assert_response :success
  end

  test "should get privacy" do
    get privacy_path
    assert_response :success
  end

  test "should get contact" do
    get contact_path
    assert_response :success
  end

  test "consent with all sets both cookies" do
    post consent_path, params: { consent: "all" }

    assert_response :redirect
    assert_equal "true", cookies[:cookie_consent_given]
    assert_equal "true", cookies[:analytics_consent]
  end

  test "consent with necessary sets only consent cookie" do
    post consent_path, params: { consent: "necessary" }

    assert_response :redirect
    assert_equal "true", cookies[:cookie_consent_given]
    assert_equal "false", cookies[:analytics_consent]
  end

  test "consent redirects back" do
    get root_path
    post consent_path, params: { consent: "all" }, headers: { "HTTP_REFERER" => root_path }

    assert_redirected_to root_path
  end
end
