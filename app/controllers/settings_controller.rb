class SettingsController < ApplicationController
  before_action :authenticate_user!

  def edit
    @user = current_user
    @newsletter_subscription = NewsletterSubscription.find_by(email: current_user.email)
  end

  def export_data
    service = UserExportService.new(current_user)

    send_data service.to_json,
              filename: "tabdevs-export-#{Date.current}.json",
              type: "application/json"
  end

  def destroy
    UserDeletionService.new(current_user).delete!
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
    result = NewsletterSubscriptionService.new(current_user.email, auto_confirm: true).subscribe
    redirect_to settings_path, notice: t("flash.settings.newsletter_#{result.message_key}")
  end

  def unsubscribe_newsletter
    result = NewsletterSubscriptionService.new(current_user.email).unsubscribe

    if result.success
      redirect_to settings_path, notice: t("flash.settings.newsletter_#{result.message_key}")
    else
      redirect_to settings_path, alert: t("flash.settings.newsletter_#{result.message_key}")
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :bio, :website, :github_username, :twitter_username, :linkedin_url, :email_notifications)
  end
end
