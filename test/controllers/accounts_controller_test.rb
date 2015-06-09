require 'test_helper'

class AccountsControllerTest < ActionController::TestCase
  
  def setup
    @itlinux_user = users(:itlinux_user)
    @itlinux = accounts(:itlinux)
  end
  
  test "create should response unauthorized for users accounts" do
    sign_in @itlinux_user
    get :index
    assert_response 403
    get :show, id: @itlinux.id
    assert_response 403
  end
  
end
