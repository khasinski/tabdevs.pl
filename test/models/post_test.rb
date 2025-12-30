require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "validates title presence" do
    post = build(:post, title: nil)
    assert_not post.valid?
    assert_includes post.errors[:title], I18n.t("activerecord.errors.messages.blank")
  end

  test "validates title length" do
    post = build(:post, title: "ab")
    assert_not post.valid?

    post = build(:post, title: "a" * 121)
    assert_not post.valid?
  end

  test "requires url for link posts" do
    post = build(:post, post_type: :link, url: nil)
    assert_not post.valid?
    assert_includes post.errors[:url], "jest wymagany dla postów typu link"
  end

  test "text posts don't require url" do
    post = build(:post, :text)
    assert post.valid?
  end

  test "normalizes url by adding https" do
    post = build(:post, url: "http://example.com/page")
    post.save!
    assert_equal "http://example.com/page", post.url

    # Test that urls without protocol get https added
    post2 = build(:post, url: nil)
    post2.url = "example.com/page"
    post2.run_callbacks(:save) { false }  # Run before_save without saving
    assert_equal "https://example.com/page", post2.url
  end

  test "extracts domain from url" do
    post = build(:post, url: "https://www.example.com/path")
    assert_equal "example.com", post.domain
  end

  test "upvote increases score" do
    post = create(:post)
    user = create(:user)

    assert_difference -> { post.reload.score }, 1 do
      post.upvote!(user)
    end
  end

  test "downvote decreases score" do
    post = create(:post)
    user = create(:user, karma: 100)

    assert_difference -> { post.reload.score }, -1 do
      post.downvote!(user)
    end
  end

  test "downvote fails for low karma users" do
    SiteSetting.set(:downvote_threshold, 10)
    post = create(:post)
    user = create(:user, karma: 5)

    assert_not post.downvote!(user)
  end

  test "remove_vote restores score" do
    post = create(:post, score: 5)
    user = create(:user)
    post.upvote!(user)

    assert_difference -> { post.reload.score }, -1 do
      post.remove_vote!(user)
    end
  end

  test "editable? returns true within grace period" do
    SiteSetting.set(:edit_grace_period_minutes, 15)
    post = create(:post, created_at: 10.minutes.ago)

    assert post.editable?
  end

  test "editable? returns false after grace period" do
    SiteSetting.set(:edit_grace_period_minutes, 15)
    post = create(:post, created_at: 20.minutes.ago)

    assert_not post.editable?
  end

  test "can_be_edited_by? allows author within grace period" do
    SiteSetting.set(:edit_grace_period_minutes, 15)
    user = create(:user)
    post = create(:post, author: user, created_at: 10.minutes.ago)

    assert post.can_be_edited_by?(user)
  end

  test "can_be_edited_by? allows admin anytime" do
    admin = create(:user, :admin)
    post = create(:post, created_at: 1.day.ago)

    assert post.can_be_edited_by?(admin)
  end

  test "by_top scope orders by ranking formula" do
    old_popular = create(:post, score: 100, created_at: 2.days.ago)
    new_medium = create(:post, score: 10, created_at: 1.hour.ago)

    top_posts = Post.by_top.to_a
    # Newer post with medium score should rank higher than old popular post
    assert top_posts.first == new_medium
  end

  test "find_duplicate finds similar urls" do
    SiteSetting.set(:duplicate_url_days, 365)
    existing = create(:post, url: "https://example.com/article", score: 10)

    duplicate = Post.find_duplicate("https://example.com/article")
    assert_equal existing, duplicate
  end
end
