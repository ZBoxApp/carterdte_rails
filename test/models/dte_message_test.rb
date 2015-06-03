require 'test_helper'

class DteMessageTest < ActiveSupport::TestCase

  def setup
    @envio = dte_messages(:envio)
  end

  test "email should be lowercase" do
    @envio.save
    assert_equal(@envio.to.downcase, @envio.to)
    assert_equal(@envio.from.downcase, @envio.from)
  end
  
    

end
