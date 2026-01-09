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
    level3 = create(:comment, post: post, parent: level2)
    level4 = create(:comment, post: post, parent: level3)

    assert_equal 0, level0.depth
    assert_equal 1, level1.depth
    assert_equal 2, level2.depth
    assert_equal 3, level3.depth
    assert_equal 4, level4.depth
  end

  test "enforces max nesting depth at 5 levels" do
    post = create(:post)
    level0 = create(:comment, post: post, parent: nil)
    level1 = create(:comment, post: post, parent: level0)
    level2 = create(:comment, post: post, parent: level1)
    level3 = create(:comment, post: post, parent: level2)
    level4 = create(:comment, post: post, parent: level3)
    level5 = build(:comment, post: post, parent: level4)

    assert_not level5.valid?
    assert_includes level5.errors[:parent], I18n.t("activerecord.errors.models.comment.attributes.parent.max_nesting")
  end

  test "can_reply? returns true for depth < 4" do
    post = create(:post)
    level0 = create(:comment, post: post)
    level1 = create(:comment, post: post, parent: level0)
    level2 = create(:comment, post: post, parent: level1)
    level3 = create(:comment, post: post, parent: level2)
    level4 = create(:comment, post: post, parent: level3)

    assert level0.can_reply?
    assert level1.can_reply?
    assert level2.can_reply?
    assert level3.can_reply?
    assert_not level4.can_reply?
  end

  test "reply_parent_id returns comment id for depth < 4" do
    post = create(:post)
    level0 = create(:comment, post: post)
    level1 = create(:comment, post: post, parent: level0)
    level2 = create(:comment, post: post, parent: level1)
    level3 = create(:comment, post: post, parent: level2)

    assert_equal level0.id, level0.reply_parent_id
    assert_equal level1.id, level1.reply_parent_id
    assert_equal level2.id, level2.reply_parent_id
    assert_equal level3.id, level3.reply_parent_id
  end

  test "reply_parent_id returns parent_id for depth >= 4 (sibling reply)" do
    post = create(:post)
    level0 = create(:comment, post: post)
    level1 = create(:comment, post: post, parent: level0)
    level2 = create(:comment, post: post, parent: level1)
    level3 = create(:comment, post: post, parent: level2)
    level4 = create(:comment, post: post, parent: level3)

    # At max depth, reply goes to same level (sibling)
    assert_equal level3.id, level4.reply_parent_id
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
