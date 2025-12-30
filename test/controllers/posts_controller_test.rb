require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @post = create(:post, author: @user)
  end

  # Index
  test "shows posts feed" do
    get root_path
    assert_response :success
    assert_includes response.body, @post.title
  end

  test "shows posts sorted by new" do
    get new_posts_path
    assert_response :success
  end

  # Show
  test "shows single post" do
    get post_path(@post)
    assert_response :success
    assert_includes response.body, @post.title
  end

  # New
  test "requires login for new post" do
    get new_post_path
    assert_redirected_to login_path
  end

  test "shows new post form for logged in user" do
    login_user(@user)
    get new_post_path
    assert_response :success
    assert_includes response.body, I18n.t("views.posts.new_post")
  end

  # Create
  test "requires login to create post" do
    post posts_path, params: { post: { title: "Test", url: "https://example.com" } }
    assert_redirected_to login_path
  end

  test "creates link post" do
    login_user(@user)

    assert_difference "Post.count", 1 do
      post posts_path, params: { post: { title: "Test Link", url: "https://example.com/new" } }
    end

    new_post = Post.last
    assert_equal "Test Link", new_post.title
    assert_equal "https://example.com/new", new_post.url
    assert new_post.link?
    assert_redirected_to post_path(new_post)
  end

  test "creates text post" do
    login_user(@user)

    assert_difference "Post.count", 1 do
      post posts_path, params: { post: { title: "Test Text", body: "Some content here" } }
    end

    new_post = Post.last
    assert new_post.text?
  end

  test "detects duplicate URL and redirects" do
    existing = create(:post, url: "https://example.com/dup", score: 10)
    login_user(@user)

    assert_no_difference "Post.count" do
      post posts_path, params: { post: { title: "Duplicate", url: "https://example.com/dup" } }
    end

    assert_redirected_to post_path(existing)
    assert_match I18n.t("flash.posts.duplicate"), flash[:notice]
  end

  # Edit
  test "requires login for edit" do
    get edit_post_path(@post)
    assert_redirected_to login_path
  end

  test "allows author to edit within grace period" do
    login_user(@user)
    get edit_post_path(@post)
    assert_response :success
  end

  test "denies edit after grace period" do
    @post.update_column(:created_at, 1.hour.ago)
    login_user(@user)

    get edit_post_path(@post)
    assert_redirected_to post_path(@post)
    assert_equal I18n.t("flash.posts.edit_not_allowed"), flash[:alert]
  end

  test "allows admin to edit anytime" do
    admin = create(:user, :admin)
    @post.update_column(:created_at, 1.day.ago)
    login_user(admin)

    get edit_post_path(@post)
    assert_response :success
  end

  # Update
  test "updates post" do
    login_user(@user)
    patch post_path(@post), params: { post: { title: "Updated Title" } }

    @post.reload
    assert_equal "Updated Title", @post.title
    assert_redirected_to post_path(@post)
  end

  # Destroy
  test "soft deletes post" do
    login_user(@user)
    delete post_path(@post)

    @post.reload
    assert @post.removed?
    assert_redirected_to root_path
  end

  # Voting
  test "upvotes post" do
    login_user(@user)
    assert_difference -> { @post.reload.score }, 1 do
      post upvote_post_path(@post)
    end
  end

  test "removes vote from post" do
    @post.upvote!(@user)
    login_user(@user)

    assert_difference -> { @post.reload.score }, -1 do
      delete remove_vote_post_path(@post)
    end
  end

  private

  def login_user(user)
    magic_link = user.magic_links.create!(token: SecureRandom.urlsafe_base64(32), expires_at: 1.hour.from_now)
    get auth_callback_path(token: magic_link.token)
  end
end
