require 'test_helper'

## /test/integration/users_signup_test.rb
class UsersSignupTest < ActionDispatch::IntegrationTest

  test 'should reject invalid signup attempt' do
    get signup_path
    assert_select 'form[action="/signup"]'

    assert_no_difference 'User.count' do
      post signup_path, params: {
        user:
        {
          name: ' ', email: ' ', password: ' ', password_confirmation: '  '
        }
      }
    end

    assert_template 'users/new'
    assert_select 'div#error_explanation'
    assert_select 'div.alert'
    assert_select 'div#error_explanation ul>li', 5
    assert_not flash[:danger].blank?
  end

  test 'should accept valid signup attempt' do
    get signup_path
    assert_select 'form[action="/signup"]'
    assert_difference 'User.count' do
      post signup_path, params: {
        user: {
          name: 'Example User',
          email: 'user@example.com',
          password: 'password',
          password_confirmation: 'password',
        }
      }
    end
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
    assert_not flash[:success].blank?
  end

end
