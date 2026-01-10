require "test_helper"

module Admin
  class FlagsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin = create(:user, :admin)
      @flag = create(:flag)
    end

    test "requires admin for index" do
      user = create(:user)
      login_user(user)
      get admin_flags_path
      assert_redirected_to root_path
    end

    test "shows flags index for admin" do
      login_user(@admin)
      get admin_flags_path
      assert_response :success
    end

    test "shows only pending flags" do
      resolved_flag = create(:flag, :resolved)
      login_user(@admin)

      get admin_flags_path

      assert_includes response.body, @flag.user.username
    end

    test "resolves flag" do
      login_user(@admin)

      post resolve_admin_flag_path(@flag)

      @flag.reload
      assert @flag.resolved?
      assert_equal @admin, @flag.resolved_by
      assert_redirected_to admin_flags_path
      assert_equal I18n.t("admin.flash.flag_resolved"), flash[:notice]
    end

    test "resolves flag and hides content" do
      flag = create(:flag, flaggable: create(:post))
      login_user(@admin)

      post resolve_admin_flag_path(flag), params: { hide_content: "1" }

      flag.reload
      assert flag.resolved?
      assert flag.flaggable.hidden?
    end

    test "dismisses flag" do
      login_user(@admin)

      post dismiss_admin_flag_path(@flag)

      @flag.reload
      assert @flag.resolved?
      assert_redirected_to admin_flags_path
      assert_equal I18n.t("admin.flash.flag_dismissed"), flash[:notice]
    end

    test "displays flaggable content" do
      post = create(:post, title: "Flagged Post")
      flag = create(:flag, flaggable: post)
      login_user(@admin)

      get admin_flags_path

      assert_includes response.body, "Flagged Post"
    end

    test "handles flag on comment" do
      comment = create(:comment, body: "Flagged comment")
      flag = create(:flag, flaggable: comment)
      login_user(@admin)

      get admin_flags_path

      assert_includes response.body, "Flagged comment"
    end
  end
end
