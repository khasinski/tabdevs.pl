require "test_helper"

class BookmarkTest < ActiveSupport::TestCase
  test "valid bookmark" do
    bookmark = build(:bookmark)
    assert bookmark.valid?
  end

  test "requires user" do
    bookmark = build(:bookmark, user: nil)
    assert_not bookmark.valid?
    assert bookmark.errors[:user].present?
  end

  test "requires post" do
    bookmark = build(:bookmark, post: nil)
    assert_not bookmark.valid?
    assert bookmark.errors[:post].present?
  end

  test "validates uniqueness of user_id scoped to post_id" do
    user = create(:user)
    post = create(:post)
    create(:bookmark, user: user, post: post)

    duplicate = build(:bookmark, user: user, post: post)
    assert_not duplicate.valid?
    assert duplicate.errors[:user_id].present?
  end

  test "same user can bookmark different posts" do
    user = create(:user)
    post1 = create(:post)
    post2 = create(:post)

    bookmark1 = create(:bookmark, user: user, post: post1)
    bookmark2 = build(:bookmark, user: user, post: post2)

    assert bookmark2.valid?
  end

  test "different users can bookmark same post" do
    user1 = create(:user)
    user2 = create(:user)
    post = create(:post)

    bookmark1 = create(:bookmark, user: user1, post: post)
    bookmark2 = build(:bookmark, user: user2, post: post)

    assert bookmark2.valid?
  end
end
