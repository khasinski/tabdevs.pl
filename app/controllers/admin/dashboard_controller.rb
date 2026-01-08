module Admin
  class DashboardController < BaseController
    def show
      @stats = {
        users: User.count,
        posts: Post.count,
        comments: Comment.count,
        pending_moderation: ModerationItem.pending_review.count,
        pending_flags: Flag.pending.count
      }
      @recent_users = User.order(created_at: :desc).limit(10)
      @recent_posts = Post.includes(:author).order(created_at: :desc).limit(10)
    end
  end
end
