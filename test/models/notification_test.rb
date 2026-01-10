require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  test "valid notification" do
    notification = build(:notification)
    assert notification.valid?
  end

  test "requires user" do
    notification = build(:notification, user: nil)
    assert_not notification.valid?
  end

  test "requires notifiable" do
    notification = build(:notification, notifiable: nil)
    assert_not notification.valid?
  end

  test "read? returns false for unread notification" do
    notification = build(:notification, read_at: nil)
    assert_not notification.read?
  end

  test "read? returns true for read notification" do
    notification = build(:notification, :read)
    assert notification.read?
  end

  test "mark_as_read! sets read_at" do
    notification = create(:notification)
    assert_nil notification.read_at

    notification.mark_as_read!

    assert_not_nil notification.read_at
    assert notification.read?
  end

  test "mark_as_read! does not update already read notification" do
    original_time = 1.hour.ago
    notification = create(:notification, read_at: original_time)

    notification.mark_as_read!

    assert_in_delta original_time.to_i, notification.read_at.to_i, 1
  end

  test "mark_all_as_read! marks all unread notifications for user" do
    user = create(:user)
    notification1 = create(:notification, user: user)
    notification2 = create(:notification, user: user)
    notification3 = create(:notification, :read, user: user)

    Notification.mark_all_as_read!(user)

    assert notification1.reload.read?
    assert notification2.reload.read?
    assert notification3.reload.read?
  end

  test "unread scope returns only unread notifications" do
    user = create(:user)
    unread = create(:notification, user: user)
    read = create(:notification, :read, user: user)

    results = user.notifications.unread

    assert_includes results, unread
    assert_not_includes results, read
  end

  test "read scope returns only read notifications" do
    user = create(:user)
    unread = create(:notification, user: user)
    read = create(:notification, :read, user: user)

    results = user.notifications.read

    assert_not_includes results, unread
    assert_includes results, read
  end

  test "recent scope orders by created_at desc" do
    user = create(:user)
    old = create(:notification, user: user, created_at: 2.days.ago)
    new = create(:notification, user: user, created_at: 1.hour.ago)

    results = user.notifications.recent

    assert_equal new, results.first
    assert_equal old, results.last
  end

  test "notification_type enum works correctly" do
    comment_reply = build(:notification, notification_type: :comment_reply)
    post_comment = build(:notification, notification_type: :post_comment)
    mention = build(:notification, notification_type: :mention)

    assert comment_reply.comment_reply?
    assert post_comment.post_comment?
    assert mention.mention?
  end
end
