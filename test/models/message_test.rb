require 'test_helper'

class MessageTest < ActiveSupport::TestCase

  def setup
    @admin_account = accounts(:itlinux)
    @zbox_account = accounts(:zbox_client)
    @itlinux_account = accounts(:itlinux_client)
    date = Date.parse('2015-05-16')
    @base_query = { s_date: date, e_date: date }
  end

  test 'self.search should rais if no account passed' do
    assert_raise(RuntimeError) { Message.search }
  end

  test 'self.search should return a SLResult with an array of messages' do
    @base_query[:account] = @admin_account
    result = Message.search(@base_query)
    assert_equal(Message, result.results.first.class)
  end

  test 'result should respond to the apropiate info' do
    @base_query[:account] = @admin_account
    search = Message.search(@base_query)
    msg = search.results.first
    assert_equal 'AU1fK5QmnuGUxTCvj0lc', msg.id
    assert_equal 'af634e4ea6a3dcbe2994a930dc8ad5eb8b8.20150516235926@mail64.atl71.mcdlv.net', msg.messageid
    assert_equal 'bounce-mc.us10_41744441.191829-JAMORANDE=KIKE21.CL@mail64.atl71.mcdlv.net', msg.from
    assert_equal 'jamorande@kike21.cl', msg.to.first
    assert_equal 'mail64.atl71.mcdlv.net', msg.from_domain
    assert_equal 'kike21.cl', msg.to_domain.first
    assert_equal 'CLEAN', msg.result
    assert_equal 'Passed', msg.status
    assert_equal 21_265, msg.size
  end

  test 'zbox_account should only get their results' do
    @base_query[:account] = @zbox_account
    result = Message.search(@base_query)
    first = result.hits.first._source
    assert [first.to_domain, first.from_domain].include?(domains(:ind).name)
  end

  test 'itlinux_client should only get their results' do
    @base_query[:account] = @itlinux_account
    result = Message.search(@base_query)
    first = result.hits.first._source
  end

  test 'find should rails ActiveRecord::RecordNotFound for invalid ids' do
    assert_raise(ActiveRecord::RecordNotFound) { Message.find(@itlinux_account, 9383) }
  end

  test 'find should return the given message' do
    msg = Message.find(@admin_account, 'AU1fK5QmnuGUxTCvj0lc')
    assert_equal 'AU1fK5QmnuGUxTCvj0lc', msg.id
    assert_equal 'jamorande@kike21.cl', msg.to.first
    assert_equal 'mail64.atl71.mcdlv.net', msg.from_domain
    assert_equal 'kike21.cl', msg.to_domain.first
    assert_equal 'CLEAN', msg.result
    assert_equal 'Passed', msg.status
    assert_equal Time.parse('2015-05-16T23:59:58.769Z'), msg.timestamp
  end

  test 'qids should return all the queueids for the message' do
    q_from_es = %w(77DA3284DBE AD163284DBF BCD8B284DBE)
    msg = Message.find(@admin_account, 'AU1fK5QmnuGUxTCvj0lc')
    qids = msg.qids
    assert qids.is_a?(Array), 'Deberia ser un Array'
    assert_equal q_from_es.sort, qids.sort
  end

  test 'delivery_status should return the status you know what' do
    assert false
  end



end
