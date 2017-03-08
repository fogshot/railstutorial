require 'test_helper'

## /test/controllers/sessions_controller_test.rb
class SessionsControllerTest < ActionDispatch::IntegrationTest

  test "should get new" do
    get login_path
    assert_response :success
  end

end
