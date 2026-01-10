class UserExportService
  def initialize(user)
    @user = user
  end

  def export
    {
      user: {
        username: @user.username,
        email: @user.email,
        karma: @user.karma,
        bio: @user.bio,
        website: @user.website,
        github_username: @user.github_username,
        twitter_username: @user.twitter_username,
        linkedin_url: @user.linkedin_url,
        created_at: @user.created_at
      },
      posts: @user.posts.map { |p| export_post(p) },
      comments: @user.comments.map { |c| export_comment(c) },
      bookmarks: @user.bookmarks.includes(:post).map { |b| export_bookmark(b) }
    }
  end

  def to_json
    export.to_json
  end

  private

  def export_post(post)
    {
      id: post.id,
      title: post.title,
      url: post.url,
      body: post.body,
      tag: post.tag,
      score: post.score,
      comments_count: post.comments_count,
      created_at: post.created_at
    }
  end

  def export_comment(comment)
    {
      id: comment.id,
      body: comment.body,
      post_id: comment.post_id,
      parent_id: comment.parent_id,
      score: comment.score,
      created_at: comment.created_at
    }
  end

  def export_bookmark(bookmark)
    {
      post_id: bookmark.post_id,
      post_title: bookmark.post.title,
      created_at: bookmark.created_at
    }
  end
end
