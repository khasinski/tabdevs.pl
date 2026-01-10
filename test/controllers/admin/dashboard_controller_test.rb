require "test_helper"

module Admin
  class DashboardControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin = create(:user, :admin)
      @user = create(:user)
    end

    test "requires login" do
      get admin_dashboard_path
      assert_redirected_to root_path
    end

    test "requires admin role" do
      login_user(@user)
      get admin_dashboard_path
      assert_redirected_to root_path
      assert_equal I18n.t("flash.auth.no_permission"), flash[:alert]
    end

    test "shows dashboard for admin" do
      login_user(@admin)
      get admin_dashboard_path
      assert_response :success
    end

    test "displays stats" do
      create_list(:post, 3)
      create_list(:comment, 5)
      create(:moderation_item, status: :pending)
      create(:flag)

      login_user(@admin)
      get admin_dashboard_path

      assert_response :success
    end

    test "displays recent users" do
      new_user = create(:user, username: "newuser")
      login_user(@admin)

      get admin_dashboard_path

      assert_includes response.body, "newuser"
    end

    test "displays recent posts" do
      post = create(:post, title: "Recent Post Title")
      login_user(@admin)

      get admin_dashboard_path

      assert_includes response.body, "Recent Post Title"
    end

    test "moderator cannot access dashboard" do
      moderator = create(:user, :moderator)
      login_user(moderator)

      get admin_dashboard_path
      assert_redirected_to root_path
    end
  end
end
