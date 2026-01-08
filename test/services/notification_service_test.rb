require "test_helper"

class NotificationServiceTest < ActiveSupport::TestCase
  setup do
    @post_author = create(:user)
    @commenter = create(:user)
    @post = create(:post, author: @post_author)
  end

  test "notifies post author on new comment" do
    comment = create(:comment, post: @post, author: @commenter)

    assert_difference -> { Notification.count }, 1 do
      NotificationService.notify_on_comment(comment)
    end

    notification = Notification.last
    assert_equal @post_author, notification.user
    assert_equal "post_comment", notification.notification_type
    assert_equal comment, notification.notifiable
    assert_equal @commenter, notification.actor
  end

  test "does not notify when commenting on own post" do
    comment = create(:comment, post: @post, author: @post_author)

    assert_no_difference -> { Notification.count } do
      NotificationService.notify_on_comment(comment)
    end
  end

  test "notifies parent comment author on reply" do
    parent = create(:comment, post: @post, author: @commenter)
    replier = create(:user)
    reply = create(:comment, post: @post, author: replier, parent: parent)

    assert_difference -> { Notification.count }, 1 do
      NotificationService.notify_on_comment(reply)
    end

    notification = Notification.last
    assert_equal @commenter, notification.user
    assert_equal "comment_reply", notification.notification_type
    assert_equal reply, notification.notifiable
    assert_equal replier, notification.actor
  end

  test "does not notify when replying to own comment" do
    parent = create(:comment, post: @post, author: @commenter)
    reply = create(:comment, post: @post, author: @commenter, parent: parent)

    assert_no_difference -> { Notification.count } do
      NotificationService.notify_on_comment(reply)
    end
  end

  test "notifies mentioned users in comment" do
    mentioned = create(:user, username: "mentioned_user")
    comment = build(:comment, post: @post, author: @commenter, body: "Hey @mentioned_user check this out")
    comment.save(validate: false) # Skip callbacks to test service directly

    # 1 for post author, 1 for mention
    assert_difference -> { Notification.count }, 2 do
      NotificationService.notify_on_comment(comment)
    end

    mention_notification = Notification.where(notification_type: :mention).last
    assert_equal mentioned, mention_notification.user
    assert_equal "mention", mention_notification.notification_type
    assert_equal @commenter, mention_notification.actor
  end

  test "does not notify when mentioning self" do
    comment = build(:comment, post: @post, author: @commenter, body: "Hey @#{@commenter.username} check this out")
    comment.save(validate: false)

    # Only 1 notification for post author, not for self-mention
    assert_difference -> { Notification.count }, 1 do
      NotificationService.notify_on_comment(comment)
    end

    assert_equal "post_comment", Notification.last.notification_type
  end

  test "does not double-notify post author when also mentioned" do
    comment = build(:comment, post: @post, author: @commenter, body: "Hey @#{@post_author.username} check this out")
    comment.save(validate: false)

    # Only 1 notification for post author (not 2)
    assert_difference -> { Notification.count }, 1 do
      NotificationService.notify_on_comment(comment)
    end
  end
end
