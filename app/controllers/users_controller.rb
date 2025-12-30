class UsersController < ApplicationController
  def show
    @user = User.find_by!(username: params[:username])
    @posts = @user.posts.visible.recent.limit(10)
    @comments = @user.comments.visible.recent.includes(:post).limit(10)
  end
end
