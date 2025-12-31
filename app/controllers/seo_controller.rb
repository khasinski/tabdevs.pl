class SeoController < ApplicationController
  def sitemap
    @posts = Post.visible.order(created_at: :desc).limit(1000)
    @users = User.where(status: :active).order(created_at: :desc).limit(500)

    respond_to do |format|
      format.xml { render layout: false }
    end
  end

  def feed
    @posts = Post.visible.order(created_at: :desc).limit(50)

    respond_to do |format|
      format.rss { render layout: false }
    end
  end
end
