class SettingsController < ApplicationController
  before_action :authenticate_user!

  def edit
    @user = current_user
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
