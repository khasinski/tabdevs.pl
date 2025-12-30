require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @post = create(:post)
    @comment = create(:comment, post: @post, author: @user)
  end

  # Create
  test "requires login to create comment" do
    post post_comments_path(@post), params: { comment: { body: "Test" } }
    assert_redirected_to login_path
  end

  test "creates comment on post" do
    login_user(@user)

    assert_difference "Comment.count", 1 do
      post post_comments_path(@post), params: { comment: { body: "Great post!" } }
    end

    comment = Comment.last
    assert_equal "Great post!", comment.body
    assert_equal @post, comment.post
    assert_equal @user, comment.author
  end

  test "creates reply to comment" do
    login_user(@user)

    assert_difference "Comment.count", 1 do
      post post_comments_path(@post), params: { comment: { body: "Reply", parent_id: @comment.id } }
    end

    reply = Comment.last
    assert_equal @comment, reply.parent
  end

  test "auto-upvotes own comment" do
    login_user(@user)
    post post_comments_path(@post), params: { comment: { body: "New comment" } }

    comment = Comment.last
    assert_equal 1, comment.score
    assert @user.voted_for?(comment)
  end

  # Edit
  test "requires login for edit" do
    get edit_post_comment_path(@post, @comment)
    assert_redirected_to login_path
  end

  test "allows author to edit within grace period" do
    login_user(@user)
    get edit_post_comment_path(@post, @comment)
    assert_response :success
  end

  test "denies edit after grace period" do
    @comment.update_column(:created_at, 1.hour.ago)
    login_user(@user)

    get edit_post_comment_path(@post, @comment)
    assert_redirected_to post_path(@post)
  end

  # Update
  test "updates comment" do
    login_user(@user)
    patch post_comment_path(@post, @comment), params: { comment: { body: "Updated body" } }

    @comment.reload
    assert_equal "Updated body", @comment.body
    assert @comment.edited?
  end

  # Destroy
  test "soft deletes comment" do
    login_user(@user)
    delete post_comment_path(@post, @comment)

    @comment.reload
    assert @comment.removed?
  end

  # Voting
  test "upvotes comment" do
    other_user = create(:user)
    login_user(other_user)

    assert_difference -> { @comment.reload.score }, 1 do
      post upvote_comment_path(@comment)
    end
  end

  test "downvotes comment with sufficient karma" do
    other_user = create(:user, karma: 100)
    login_user(other_user)

    assert_difference -> { @comment.reload.score }, -1 do
      post downvote_comment_path(@comment)
    end
  end

  test "denies downvote with insufficient karma" do
    SiteSetting.set(:downvote_threshold, 10)
    other_user = create(:user, karma: 0)
    login_user(other_user)

    assert_no_difference -> { @comment.reload.score } do
      post downvote_comment_path(@comment)
    end
    assert_equal I18n.t("flash.votes.downvote_karma"), flash[:alert]
  end

  private

  def login_user(user)
    magic_link = user.magic_links.create!(token: SecureRandom.urlsafe_base64(32), expires_at: 1.hour.from_now)
    get auth_callback_path(token: magic_link.token)
  end
end
