class SettingsController < ApplicationController
  before_action :authenticate_user!

  def edit
    @user = current_user
  end

  def export_data
    @user = current_user
    data = {
      user: {
        username: @user.username,
        email: @user.email,
        karma: @user.karma,
        created_at: @user.created_at
      },
      posts: @user.posts.map { |p| { title: p.title, url: p.url, body: p.body, created_at: p.created_at } },
      comments: @user.comments.map { |c| { body: c.body, post_id: c.post_id, created_at: c.created_at } }
    }

    send_data data.to_json,
              filename: "tabdevs-export-#{Date.current}.json",
              type: "application/json"
  end

  def destroy
    @user = current_user

    # Find or create a "deleted" user for anonymization
    deleted_user = User.find_or_create_by!(email: "deleted@tabdevs.pl") do |u|
      u.username = "usuniety"
      u.role = :user
      u.status = :active
    end

    ActiveRecord::Base.transaction do
      # Transfer posts and comments to deleted user
      @user.posts.update_all(author_id: deleted_user.id)
      @user.comments.update_all(author_id: deleted_user.id)

      # Nullify actor references in notifications
      Notification.where(actor_id: @user.id).update_all(actor_id: nil)

      # Delete associated records
      @user.notifications.delete_all
      @user.votes.delete_all
      @user.magic_links.delete_all
      @user.bans.delete_all

      # Delete user account
      @user.destroy!
    end

    reset_session
    redirect_to root_path, notice: t("flash.settings.account_deleted")
  end

  def update
    @user = current_user

    if @user.update(user_params)
      redirect_to settings_path, notice: t("flash.settings.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def update_password
    @user = current_user

    if params[:password].blank?
      @user.errors.add(:password, :blank)
      return render :edit, status: :unprocessable_entity
    end

    if params[:password] != params[:password_confirmation]
      @user.errors.add(:password_confirmation, :confirmation)
      return render :edit, status: :unprocessable_entity
    end

    if params[:password].length < 8
      @user.errors.add(:password, :too_short, count: 8)
      return render :edit, status: :unprocessable_entity
    end

    @user.password = params[:password]

    if @user.save
      redirect_to settings_path, notice: t("flash.settings.password_updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:username)
  end
end
