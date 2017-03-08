require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @admin = users(:alice)
    @other_user = users(:bob)
  end

  test 'index including pagination' do
    log_in_as(@user)
    get users_path
    assert_template 'users/index'
    assert_select '.pagination'
    User.paginate(page: 1).each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
    end
  end

  test 'admin can delete user' do
    log_in_as(@admin)
    assert_difference 'User.count', -1 do
      delete user_path(@other_user)
    end
  end

  test 'index as non-admin' do
    log_in_as(@user)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end

end
