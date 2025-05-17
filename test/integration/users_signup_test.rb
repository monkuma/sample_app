require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  test "invalid sigunp information" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, params: { user: { name: '',
                                        email: 'user@invalid',
                                        password: 'for',
                                        password_confirmation: 'bar' } }
    end
    assert_response :unprocessable_entity
    assert_template 'users/new'
    assert_select 'div#error_explanation'
    assert_select 'div.field_with_errors'
  end

  test "valit signup information" do
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name: "Example User",
                                         email: "user@example.com",
                                         password: "password321",
                                         password_confirmation: "password321" } }
    end
    follow_redirect!
    assert_template 'users/show'
    assert_not flash.empty?
  end
end
