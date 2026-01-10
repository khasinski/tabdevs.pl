require "test_helper"

class FlagsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @post = create(:post)
    @comment = create(:comment, post: @post)
  end

  test "requires login for new flag on post" do
    get new_post_flag_path(@post)
    assert_redirected_to login_path
  end

  test "requires login for new flag on comment" do
    get new_comment_flag_path(@comment)
    assert_redirected_to login_path
  end

  test "shows new flag form for post" do
    login_user(@user)
    get new_post_flag_path(@post)
    assert_response :success
  end

  test "shows new flag form for comment" do
    login_user(@user)
    get new_comment_flag_path(@comment)
    assert_response :success
  end

  test "redirects if already flagged post" do
    create(:flag, user: @user, flaggable: @post)
    login_user(@user)

    get new_post_flag_path(@post)
    assert_redirected_to root_path
    assert_equal I18n.t("flash.flags.already_flagged"), flash[:alert]
  end

  test "redirects if already flagged comment" do
    create(:flag, user: @user, flaggable: @comment)
    login_user(@user)

    get new_comment_flag_path(@comment)
    assert_redirected_to root_path
    assert_equal I18n.t("flash.flags.already_flagged"), flash[:alert]
  end

  test "requires login to create flag" do
    post post_flag_path(@post), params: { flag: { reason: :spam } }
    assert_redirected_to login_path
  end

  test "creates flag for post" do
    login_user(@user)

    assert_difference "Flag.count", 1 do
      post post_flag_path(@post), params: { flag: { reason: :spam } }
    end

    flag = Flag.last
    assert_equal @post, flag.flaggable
    assert_equal @user, flag.user
    assert flag.spam?
    assert_redirected_to post_path(@post)
  end

  test "creates flag for comment" do
    login_user(@user)

    assert_difference "Flag.count", 1 do
      post comment_flag_path(@comment), params: { flag: { reason: :offensive } }
    end

    flag = Flag.last
    assert_equal @comment, flag.flaggable
    assert flag.offensive?
    assert_redirected_to post_path(@comment.post)
  end

  test "creates flag with description for other reason" do
    login_user(@user)

    post post_flag_path(@post), params: { flag: { reason: :other, description: "Custom reason" } }

    flag = Flag.last
    assert flag.other?
    assert_equal "Custom reason", flag.description
  end

  test "fails to create flag without description for other reason" do
    login_user(@user)

    assert_no_difference "Flag.count" do
      post post_flag_path(@post), params: { flag: { reason: :other } }
    end

    assert_response :unprocessable_entity
  end

  test "prevents duplicate flags" do
    create(:flag, user: @user, flaggable: @post)
    login_user(@user)

    assert_no_difference "Flag.count" do
      post post_flag_path(@post), params: { flag: { reason: :spam } }
    end

    assert_response :unprocessable_entity
  end
end
