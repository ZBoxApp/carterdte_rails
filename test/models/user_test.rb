require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  def setup
    @admin = users(:admin)
    @system = users(:system)
  end
  
  test "should return if an account is system, user " do
    assert(@admin.user?, "Failure message.")
    assert(@system.system?, "Failure message.")
  end
end
