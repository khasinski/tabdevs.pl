require "test_helper"

module Admin
  class ModerationControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin = create(:user, :admin)
      @moderation_item = create(:moderation_item, status: :pending)
    end

    test "requires admin for index" do
      user = create(:user)
      login_user(user)
      get admin_moderation_index_path
      assert_redirected_to root_path
    end

    test "shows moderation index for admin" do
      login_user(@admin)
      get admin_moderation_index_path
      assert_response :success
    end

    test "shows only pending items" do
      approved_item = create(:moderation_item, :approved)
      login_user(@admin)

      get admin_moderation_index_path

      assert_response :success
    end

    test "approves moderation item" do
      login_user(@admin)

      post approve_admin_moderation_path(@moderation_item)

      @moderation_item.reload
      assert @moderation_item.approved?
      assert_equal @admin, @moderation_item.moderator
      assert_not_nil @moderation_item.resolved_at
      assert_redirected_to admin_moderation_index_path
      assert_equal I18n.t("admin.flash.moderation_approved"), flash[:notice]
    end

    test "rejects moderation item" do
      login_user(@admin)

      post reject_admin_moderation_path(@moderation_item)

      @moderation_item.reload
      assert @moderation_item.rejected?
      assert_equal @admin, @moderation_item.moderator
      assert_redirected_to admin_moderation_index_path
      assert_equal I18n.t("admin.flash.moderation_rejected"), flash[:notice]
    end

    test "rejects and hides content" do
      post = create(:post)
      item = create(:moderation_item, moderatable: post, status: :pending)
      login_user(@admin)

      post reject_admin_moderation_path(item), params: { hide_content: "1" }

      post.reload
      assert post.hidden?
    end

    test "hides post" do
      post_to_hide = create(:post)
      login_user(@admin)

      post admin_hide_post_path(post_to_hide)

      post_to_hide.reload
      assert post_to_hide.hidden?
      assert_equal I18n.t("admin.flash.post_hidden"), flash[:notice]
    end

    test "unhides post" do
      hidden_post = create(:post, :hidden)
      login_user(@admin)

      post admin_unhide_post_path(hidden_post)

      hidden_post.reload
      assert hidden_post.active?
      assert_equal I18n.t("admin.flash.post_restored"), flash[:notice]
    end

    test "hides comment" do
      comment = create(:comment)
      login_user(@admin)

      post admin_hide_comment_path(comment)

      comment.reload
      assert comment.hidden?
      assert_equal I18n.t("admin.flash.comment_hidden"), flash[:notice]
    end

    test "unhides comment" do
      hidden_comment = create(:comment, :removed)
      hidden_comment.update_column(:status, :hidden)
      login_user(@admin)

      post admin_unhide_comment_path(hidden_comment)

      hidden_comment.reload
      assert hidden_comment.active?
      assert_equal I18n.t("admin.flash.comment_restored"), flash[:notice]
    end
  end
end
