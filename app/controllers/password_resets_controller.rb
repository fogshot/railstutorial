## /app/controllers/password_resets_controller.rb
class PasswordResetsController < ApplicationController

  before_action :user,   only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]

  def new; end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = 'We sent you an email with instructions to reset your password.'
      redirect_to root_url
    else
      flash.now[:danger] = 'Email address not found'
      render 'new'
    end
  end

  def edit; end

  def update
    if params[:user][:password].empty?
      @user.errors.add(:password, 'can\'t be empty')
      render 'edit'
    elsif @user.update_attributes(user_params)
      on_successful_password_update
    else
      render 'edit'
    end
  end

  private

  def on_successful_password_update
    log_in @user
    @user.update_attribute(:reset_digest, nil)
    flash[:success] = 'Password successfully reset.'
    redirect_to @user
  end

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def user
    @user = User.find_by(email: params[:email])
  end

  # Confirms a valid user.
  def valid_user
    return if @user && @user.activated? && @user.authenticated?(:reset, params[:id])
    redirect_to root_url
  end

  def check_expiration
    return unless @user.password_reset_expired?
    redirect_to new_password_reset_url
    flash[:danger] = 'This password reset has already expired.'
  end

end
