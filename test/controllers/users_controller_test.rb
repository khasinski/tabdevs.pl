require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user, username: "testuser")
  end

  test "shows user profile by username" do
    get user_path(@user.username)
    assert_response :success
    assert_includes response.body, @user.username
  end

  test "shows user karma" do
    @user.update!(karma: 42)
    get user_path(@user.username)
    assert_includes response.body, "42"
  end

  test "shows user's recent posts" do
    post1 = create(:post, author: @user, title: "First post by user")
    get user_path(@user.username)
    assert_includes response.body, "First post by user"
  end

  test "shows user's recent comments" do
    post = create(:post)
    comment = create(:comment, author: @user, post: post, body: "Comment by this user")
    get user_path(@user.username)
    assert_includes response.body, "Comment by this user"
  end

  test "returns 404 for non-existent user" do
    get user_path("nonexistent")
    assert_response :not_found
  end

  test "shows bot badge for bot user" do
    bot = create(:user, :bot)
    get user_path(bot.username)
    assert_includes response.body, "bot"
  end
end
