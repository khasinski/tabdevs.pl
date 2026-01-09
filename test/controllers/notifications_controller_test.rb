require "test_helper"

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @post = create(:post, author: @user)
  end

  test "requires login for notifications" do
    get notifications_path
    assert_redirected_to login_path
  end

  test "shows notifications page" do
    login_user(@user)
    get notifications_path
    assert_response :success
    assert_includes response.body, I18n.t("views.notifications.title")
  end

  test "shows unread notifications" do
    other_user = create(:user)
    comment = create(:comment, post: @post, author: other_user)

    login_user(@user)
    get notifications_path

    assert_response :success
    assert_includes response.body, other_user.username
  end

  test "marks notification as read" do
    other_user = create(:user)
    comment = create(:comment, post: @post, author: other_user)
    notification = @user.notifications.last

    login_user(@user)
    post mark_read_notification_path(notification)

    notification.reload
    assert notification.read?
  end

  test "marks all notifications as read" do
    other_user = create(:user)
    create(:comment, post: @post, author: other_user)
    create(:comment, post: @post, author: other_user)

    login_user(@user)
    post mark_all_read_notifications_path

    assert_redirected_to notifications_path
    assert @user.notifications.unread.count.zero?
  end
end
