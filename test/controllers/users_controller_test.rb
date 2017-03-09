require 'test_helper'

## /test/controllers/users_controller_test.rb
class UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = users :alice
    @unactivated_user = users :archer
    @other_user = users :bob
  end

  test 'should get new' do
    get signup_path
    assert_response :success
  end

  test 'should redirect index when not logged in' do
    get users_path
    assert_redirected_to login_url
  end

  test 'should redirect edit when logged in as wrong user' do
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert_not flash[:danger].empty?
    assert_redirected_to root_url
  end

  test 'should redirect update when logged in as wrong user' do
    log_in_as(@other_user)
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
    assert_not flash[:danger].empty?
    assert_redirected_to root_url
  end

  test 'should not allow the admin attribute to be edited via the web' do
    log_in_as(@other_user)
    assert_not @other_user.admin?
    patch user_path(@other_user), params: {
      user: {
        password: '',
        password_confirmation: '',
        admin: '1',
      }
    }
    assert_not @other_user.reload.admin?
  end

  test 'should redirect destroy when not logged in' do
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to login_url
  end

  test 'should redirect destroy when logged in as a non-admin' do
    log_in_as(@other_user)
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to root_url
  end

  test 'should only show activated users in index' do
    log_in_as @user
    @other_user.activated = false
    @other_user.activated_at = nil
    get users_path
    refute_match @other_user.email, response.body
  end

  test 'should only show activated user' do
    log_in_as @unactivated_user
    get user_path(@unactivated_user)
    assert_redirected_to root_url
  end

end
