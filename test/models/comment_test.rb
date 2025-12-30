require "test_helper"

class CommentTest < ActiveSupport::TestCase
  test "validates body presence" do
    comment = build(:comment, body: nil)
    assert_not comment.valid?
    assert_includes comment.errors[:body], I18n.t("activerecord.errors.messages.blank")
  end

  test "validates body length" do
    comment = build(:comment, body: "a" * 5001)
    assert_not comment.valid?
  end

  test "calculates depth correctly" do
    post = create(:post)
    level0 = create(:comment, post: post, parent: nil)
    level1 = create(:comment, post: post, parent: level0)
    level2 = create(:comment, post: post, parent: level1)

    assert_equal 0, level0.depth
    assert_equal 1, level1.depth
    assert_equal 2, level2.depth
  end

  test "enforces max nesting depth" do
    post = create(:post)
    level0 = create(:comment, post: post, parent: nil)
    level1 = create(:comment, post: post, parent: level0)
    level2 = create(:comment, post: post, parent: level1)
    level3 = build(:comment, post: post, parent: level2)

    assert_not level3.valid?
    assert_includes level3.errors[:parent], I18n.t("activerecord.errors.models.comment.attributes.parent.max_nesting")
  end

  test "can_reply? returns true for depth < 2" do
    post = create(:post)
    level0 = create(:comment, post: post)
    level1 = create(:comment, post: post, parent: level0)
    level2 = create(:comment, post: post, parent: level1)

    assert level0.can_reply?
    assert level1.can_reply?
    assert_not level2.can_reply?
  end

  test "creates notification on reply to post" do
    post_author = create(:user)
    post = create(:post, author: post_author)
    commenter = create(:user)

    assert_difference -> { post_author.notifications.count }, 1 do
      create(:comment, post: post, author: commenter)
    end
  end

  test "creates notification on reply to comment" do
    comment_author = create(:user)
    post = create(:post)
    parent = create(:comment, post: post, author: comment_author)
    replier = create(:user)

    assert_difference -> { comment_author.notifications.count }, 1 do
      create(:comment, post: post, parent: parent, author: replier)
    end
  end

  test "does not notify self on own comment" do
    user = create(:user)
    post = create(:post, author: user)

    assert_no_difference -> { user.notifications.count } do
      create(:comment, post: post, author: user)
    end
  end
end
