module Admin
  class UsersController < BaseController
    before_action :set_user, only: [:show, :update_role, :ban, :unban]

    def index
      @users = User.order(created_at: :desc)
      @pagy, @users = pagy(:offset, @users, limit: 50)
    end

    def show
      @recent_posts = @user.posts.order(created_at: :desc).limit(10)
      @recent_comments = @user.comments.order(created_at: :desc).limit(10)
      @bans = @user.bans.order(created_at: :desc)
    end

    def update_role
      new_role = params[:role]

      if %w[user moderator admin].include?(new_role)
        @user.update!(role: new_role)
        flash[:notice] = t("admin.flash.user_role_changed", username: @user.username, role: new_role)
      else
        flash[:alert] = t("flash.auth.no_permission")
      end

      redirect_to admin_user_path(@user)
    end

    def ban
      expires_at = case params[:duration]
      when "1d" then 1.day.from_now
      when "7d" then 7.days.from_now
      when "30d" then 30.days.from_now
      when "permanent" then nil
      else 1.day.from_now
      end

      ban_type = %w[soft hard].include?(params[:ban_type]) ? params[:ban_type] : :soft

      @user.bans.create!(
        moderator: current_user,
        reason: params[:reason].presence || "Naruszenie regulaminu",
        ban_type: ban_type,
        expires_at: expires_at
      )

      @user.update!(status: :banned)
      flash[:notice] = t("admin.flash.user_banned", username: @user.username)
      redirect_to admin_user_path(@user)
    end

    def unban
      @user.bans.active.update_all(expires_at: Time.current)
      @user.update!(status: :active)
      flash[:notice] = t("admin.flash.user_unbanned", username: @user.username)
      redirect_to admin_user_path(@user)
    end

    private

    def set_user
      @user = User.find(params[:id])
    end
  end
end
