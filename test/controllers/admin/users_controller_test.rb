require "test_helper"

module Admin
  class UsersControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin = create(:user, :admin)
      @user = create(:user, username: "testuser")
    end

    test "requires admin for index" do
      login_user(@user)
      get admin_users_path
      assert_redirected_to root_path
    end

    test "shows users index for admin" do
      login_user(@admin)
      get admin_users_path
      assert_response :success
      assert_includes response.body, "testuser"
    end

    test "shows user details" do
      login_user(@admin)
      get admin_user_path(@user)
      assert_response :success
      assert_includes response.body, @user.username
    end

    test "updates user role" do
      login_user(@admin)
      patch update_role_admin_user_path(@user), params: { role: "moderator" }

      @user.reload
      assert @user.moderator?
      assert_redirected_to admin_user_path(@user)
      assert_includes flash[:notice], @user.username
    end

    test "rejects invalid role" do
      login_user(@admin)
      patch update_role_admin_user_path(@user), params: { role: "invalid" }

      @user.reload
      assert @user.user?
      assert_redirected_to admin_user_path(@user)
      assert_equal I18n.t("flash.auth.no_permission"), flash[:alert]
    end

    test "bans user with soft ban" do
      login_user(@admin)

      assert_difference "Ban.count", 1 do
        post ban_admin_user_path(@user), params: {
          reason: "Test ban reason",
          duration: "7d",
          ban_type: "soft"
        }
      end

      @user.reload
      assert @user.banned?
      ban = @user.bans.last
      assert ban.soft?
      assert_equal "Test ban reason", ban.reason
      assert_redirected_to admin_user_path(@user)
    end

    test "bans user with hard ban" do
      login_user(@admin)

      post ban_admin_user_path(@user), params: {
        reason: "Serious violation",
        duration: "permanent",
        ban_type: "hard"
      }

      ban = @user.bans.last
      assert ban.hard?
      assert ban.permanent?
    end

    test "bans user with different durations" do
      login_user(@admin)

      post ban_admin_user_path(@user), params: { reason: "Test", duration: "1d" }
      ban = @user.bans.last
      assert_in_delta 1.day.from_now.to_i, ban.expires_at.to_i, 5

      @user.update!(status: :active)
      post ban_admin_user_path(@user), params: { reason: "Test", duration: "30d" }
      ban = @user.bans.last
      assert_in_delta 30.days.from_now.to_i, ban.expires_at.to_i, 5
    end

    test "unbans user" do
      create(:ban, user: @user, moderator: @admin)
      @user.update!(status: :banned)
      login_user(@admin)

      post unban_admin_user_path(@user)

      @user.reload
      assert @user.active?
      assert_redirected_to admin_user_path(@user)
    end

    test "shows user posts and comments" do
      post = create(:post, author: @user, title: "User Post Title")
      comment = create(:comment, author: @user, body: "User Comment Body")

      login_user(@admin)
      get admin_user_path(@user)

      assert_includes response.body, "User Post Title"
      assert_includes response.body, "User Comment Body"
    end

    test "shows user ban history" do
      ban = create(:ban, user: @user, moderator: @admin, reason: "Previous ban")

      login_user(@admin)
      get admin_user_path(@user)

      assert_includes response.body, "Previous ban"
    end
  end
end
