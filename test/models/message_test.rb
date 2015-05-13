require 'test_helper'

class MessageTest < ActiveSupport::TestCase

  def setup
    @envio = messages(:envio)
  end

  test "email should be lowercase" do
    @envio.save
    assert_equal(@envio.to.downcase, @envio.to)
    assert_equal(@envio.from.downcase, @envio.from)
  end

end
