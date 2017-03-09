require 'test_helper'

## /test/integration/password_resets_test.rb
class PasswordResetsTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
  end

  test 'get password reset link' do
    get new_password_reset_path
    assert_template 'password_resets/new'
    # invalid email
    post password_resets_path, params: { password_reset: { email: '' } }
    assert_not flash[:danger].empty?
    assert_template 'password_resets/new'
    # valid email
    post password_resets_path, params: { password_reset: { email: @user.email } }
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash[:info].empty?
    assert_redirected_to root_url
  end

  test 'get reset password form' do
    post password_resets_path, params: { password_reset: { email: @user.email } }
    # password reset form
    user = assigns :user
    # wrong email
    get edit_password_reset_path(user.reset_token, email: '')
    assert_redirected_to root_url
    # inactive user
    user.toggle! :activated
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_url
    user.toggle!(:activated)
    # Right email, wrong token
    get edit_password_reset_path('wrong token', email: user.email)
    assert_redirected_to root_url
    # Right email, right token
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    assert_select 'input[name=email][type=hidden][value=?]', user.email
  end

  test 'try to choose new password with invalid information' do
    post password_resets_path, params: { password_reset: { email: @user.email } }
    user = assigns :user
    # Invalid password & confirmation
    patch password_reset_path(user.reset_token), params: {
      email: user.email,
      user: {
        password:              'foo',
        password_confirmation: 'bar',
      }
    }
    assert_select '#error_explanation'
    # Empty password
    patch password_reset_path(user.reset_token), params: {
      email: user.email,
      user: {
        password:              '',
        password_confirmation: '',
      }
    }
    assert_select '#error_explanation'
  end

  test 'choose new password' do
    post password_resets_path, params: { password_reset: { email: @user.email } }
    user = assigns :user
    # Valid password & confirmation
    patch password_reset_path(user.reset_token), params: {
      email: user.email,
      user: {
        password:              'foobaz',
        password_confirmation: 'foobaz',
      }
    }
    assert is_logged_in?
    assert_not flash.empty?
    assert_nil user.reload.reset_digest
    assert_redirected_to user
  end

  test 'expired_password_reset_token' do
    post password_resets_path, params: { password_reset: { email: @user.email } }
    @user = assigns(:user)
    @user.update_attribute(:reset_sent_at, 3.hours.ago)
    get edit_password_reset_path(@user.reset_token, email: @user.email)
    assert_redirected_to new_password_reset_path
    follow_redirect!
    assert_match 'expired', response.body
    patch password_reset_path(@user.reset_token), params: {
      email: @user.email,
      user: {
        password: 'password',
        password_confirmation: 'password',
      }
    }
    assert_redirected_to new_password_reset_path
  end

end
