class SettingsController < ApplicationController
  before_action :authenticate_user!

  def edit
    @user = current_user
    @newsletter_subscription = NewsletterSubscription.find_by(email: current_user.email)
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

    @user.password = params[:password]
    @user.password_confirmation = params[:password_confirmation]

    if @user.save
      redirect_to settings_path, notice: t("flash.settings.password_updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def subscribe_newsletter
    subscription = NewsletterSubscription.find_by(email: current_user.email)

    if subscription
      if subscription.unsubscribed?
        subscription.resubscribe!
        redirect_to settings_path, notice: t("flash.settings.newsletter_resubscribed")
      elsif subscription.confirmed?
        redirect_to settings_path, notice: t("flash.settings.newsletter_already_subscribed")
      else
        NewsletterMailer.confirmation(subscription).deliver_later
        redirect_to settings_path, notice: t("flash.settings.newsletter_confirmation_resent")
      end
    else
      subscription = NewsletterSubscription.create!(email: current_user.email)
      subscription.confirm!
      redirect_to settings_path, notice: t("flash.settings.newsletter_subscribed")
    end
  end

  def unsubscribe_newsletter
    subscription = NewsletterSubscription.find_by(email: current_user.email)

    if subscription&.confirmed? && !subscription.unsubscribed?
      subscription.unsubscribe!
      redirect_to settings_path, notice: t("flash.settings.newsletter_unsubscribed")
    else
      redirect_to settings_path, alert: t("flash.settings.newsletter_not_subscribed")
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :bio, :website, :github_username, :twitter_username, :linkedin_url, :email_notifications)
  end
end
