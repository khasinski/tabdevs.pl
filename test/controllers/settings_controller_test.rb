require "test_helper"

class SettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    login_user(@user)
  end

  test "requires authentication" do
    delete logout_path
    get settings_path
    assert_redirected_to login_path
  end

  test "shows settings page" do
    get settings_path
    assert_response :success
    assert_includes response.body, I18n.t("views.settings.title")
    assert_includes response.body, @user.username
  end

  test "updates username" do
    patch settings_path, params: { user: { username: "newusername" } }
    assert_redirected_to settings_path
    assert_equal "newusername", @user.reload.username
  end

  test "rejects invalid username" do
    patch settings_path, params: { user: { username: "ab" } }
    assert_response :unprocessable_entity
  end

  test "rejects duplicate username" do
    other_user = create(:user, username: "takenname")
    patch settings_path, params: { user: { username: "takenname" } }
    assert_response :unprocessable_entity
  end

  test "sets password for user without password" do
    patch settings_password_path, params: { password: "newpassword123", password_confirmation: "newpassword123" }
    assert_redirected_to settings_path
    assert @user.reload.has_password?
    assert @user.authenticate("newpassword123")
  end

  test "changes password for user with password" do
    @user.update!(password: "oldpassword123")

    patch settings_password_path, params: { password: "newpassword123", password_confirmation: "newpassword123" }
    assert_redirected_to settings_path
    assert @user.reload.authenticate("newpassword123")
  end

  test "rejects mismatched password confirmation" do
    patch settings_password_path, params: { password: "newpassword123", password_confirmation: "different" }
    assert_response :unprocessable_entity
  end

  test "rejects short password" do
    patch settings_password_path, params: { password: "short", password_confirmation: "short" }
    assert_response :unprocessable_entity
  end

  test "rejects empty password" do
    patch settings_password_path, params: { password: "", password_confirmation: "" }
    assert_response :unprocessable_entity
  end

  test "exports user data as JSON" do
    create(:post, author: @user, title: "My post")
    create(:comment, author: @user, body: "My comment")

    get settings_export_path
    assert_response :success
    assert_equal "application/json", response.content_type

    data = JSON.parse(response.body)
    assert_equal @user.username, data["user"]["username"]
    assert_equal 1, data["posts"].size
    assert_equal 1, data["comments"].size
  end

  test "deletes account and anonymizes content" do
    post = create(:post, author: @user)
    comment = create(:comment, author: @user)

    delete settings_destroy_path

    assert_redirected_to root_path
    assert_nil User.find_by(id: @user.id)

    deleted_user = User.find_by(email: "deleted@tabdevs.pl")
    assert_equal deleted_user.id, post.reload.author_id
    assert_equal deleted_user.id, comment.reload.author_id
  end
end
