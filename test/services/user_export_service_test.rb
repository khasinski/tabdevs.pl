require "test_helper"

class UserExportServiceTest < ActiveSupport::TestCase
  setup do
    @user = create(:user,
      username: "testuser",
      email: "test@example.com",
      karma: 42,
      bio: "Test bio",
      website: "https://example.com",
      github_username: "testgithub",
      twitter_username: "testtwitter",
      linkedin_url: "https://linkedin.com/in/test"
    )
  end

  test "exports user data" do
    service = UserExportService.new(@user)
    export = service.export

    assert_equal "testuser", export[:user][:username]
    assert_equal "test@example.com", export[:user][:email]
    assert_equal 42, export[:user][:karma]
    assert_equal "Test bio", export[:user][:bio]
    assert_equal "https://example.com", export[:user][:website]
    assert_equal "testgithub", export[:user][:github_username]
    assert_equal "testtwitter", export[:user][:twitter_username]
    assert_equal "https://linkedin.com/in/test", export[:user][:linkedin_url]
    assert_not_nil export[:user][:created_at]
  end

  test "exports user posts" do
    post1 = create(:post, author: @user, title: "Post 1", url: "https://example.com/1", score: 5)
    post2 = create(:post, :text, author: @user, title: "Post 2", body: "Content")

    service = UserExportService.new(@user)
    export = service.export

    assert_equal 2, export[:posts].length

    exported_post = export[:posts].find { |p| p[:id] == post1.id }
    assert_equal "Post 1", exported_post[:title]
    assert_equal "https://example.com/1", exported_post[:url]
    assert_equal 5, exported_post[:score]
    assert_not_nil exported_post[:created_at]
  end

  test "exports user comments" do
    post = create(:post)
    comment = create(:comment, author: @user, post: post, body: "Test comment", score: 3)

    service = UserExportService.new(@user)
    export = service.export

    assert_equal 1, export[:comments].length

    exported_comment = export[:comments].first
    assert_equal comment.id, exported_comment[:id]
    assert_equal "Test comment", exported_comment[:body]
    assert_equal post.id, exported_comment[:post_id]
    assert_equal 3, exported_comment[:score]
    assert_not_nil exported_comment[:created_at]
  end

  test "exports user bookmarks" do
    post = create(:post, title: "Bookmarked Post")
    bookmark = create(:bookmark, user: @user, post: post)

    service = UserExportService.new(@user)
    export = service.export

    assert_equal 1, export[:bookmarks].length

    exported_bookmark = export[:bookmarks].first
    assert_equal post.id, exported_bookmark[:post_id]
    assert_equal "Bookmarked Post", exported_bookmark[:post_title]
    assert_not_nil exported_bookmark[:created_at]
  end

  test "to_json returns valid JSON" do
    service = UserExportService.new(@user)
    json = service.to_json

    assert_nothing_raised do
      parsed = JSON.parse(json)
      assert_equal "testuser", parsed["user"]["username"]
    end
  end

  test "exports empty arrays when user has no content" do
    empty_user = create(:user)
    service = UserExportService.new(empty_user)
    export = service.export

    assert_equal [], export[:posts]
    assert_equal [], export[:comments]
    assert_equal [], export[:bookmarks]
  end

  test "exports nested comment with parent_id" do
    post = create(:post)
    parent = create(:comment, author: create(:user), post: post)
    reply = create(:comment, author: @user, post: post, parent: parent)

    service = UserExportService.new(@user)
    export = service.export

    exported_comment = export[:comments].find { |c| c[:id] == reply.id }
    assert_equal parent.id, exported_comment[:parent_id]
  end
end
