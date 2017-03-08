require 'test_helper'

## /test/integration/users_edit_test.rb
class UsersEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:alice)
    @other_user = users(:bob)
  end

  test 'unsuccessful edit' do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: {
      user: {
        name: '',
        email: 'foo@invalid',
        password: 'foo',
        password_confirmation: 'bar',
      },
    }
    assert_template 'users/edit'
    assert_select 'div#error_explanation'
    assert_select 'div.alert'
    assert_select 'div#error_explanation ul>li', 4
  end

  test 'successful edit with friendly forwarding' do
    get edit_user_path(@user)
    log_in_as(@user)
    assert_redirected_to edit_user_url(@user)
    follow_redirect!
    assert_template 'users/edit'
    name  = 'Foo Bar'
    email = 'foo@bar.com'
    patch user_path(@user), params: {
      user: {
        name: name,
        email: email,
        password: '',
        password_confirmation: '',
      },
    }
    assert_not flash[:success].empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name, @user.name
    assert_equal email, @user.email
  end

  test 'should redirect edit when not logged in' do
    get edit_user_path(@user)
    assert_not flash[:danger].empty?
    assert_redirected_to login_url
  end

  test 'should redirect update when not logged in' do
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
    assert_not flash[:danger].empty?
    assert_redirected_to login_url
  end

end
