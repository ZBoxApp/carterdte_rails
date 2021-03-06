require 'test_helper'

class MessageTest < ActiveSupport::TestCase

  def setup
    @admin_account = accounts(:itlinux)
    @zbox_account = accounts(:zbox_client)
    @itlinux_account = accounts(:itlinux_client)
    @nojail_account = accounts(:nojail_account)
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
    msg = Message.find(@admin_account, 'AU1fK5QmnuGUxTCvj0lc')
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

  test 'find should rails Errors::NoElasticSearchResults for invalid ids' do
    assert_raise(Errors::NoElasticSearchResults) { Message.find(@itlinux_account, 9383) }
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

  test 'The first qid must be the last processed (newest date)' do
    msg = Message.find(@admin_account, 'AU1fK5QmnuGUxTCvj0lc')
    qids = msg.qids
    assert_equal 'BCD8B284DBE', qids.first
  end

  test 'delivery_status should return the status you know what' do
    msg = Message.find(@admin_account, 'AU1fK5QmnuGUxTCvj0lc')
    assert_equal 'sent', msg.delivery_status
    msg.qids_trace[msg.relay_qid][1].data['result'] = ['bounced', 'bounced']
    assert_equal 'failed', msg.delivery_status
    msg.relay_trace.delete_at(0)
    assert_equal 'enqueued', msg.delivery_status
  end

  test 'delivery_status should work with multiples relays' do
    msg = Message.find(@admin_account, 'AU2Yt-LViGpHTlo-5dPJ')
    assert_equal 'sent', msg.delivery_status
  end

  test 'logtrace should return an arrays of logs objects' do
    msg = Message.find(@admin_account, 'AU1fK5QmnuGUxTCvj0lc')
    logtrace = msg.logtrace
    assert logtrace.first.is_a?(MtaLog)
    log = logtrace.first
    assert_equal Time.parse('2015-05-16T23:59:58.856Z'), log.timestamp
    assert log.message, 'Deberia tener un mensaje'
    assert msg.qids.include?(log.qid)
  end

  test 'delay should return the time taked to process the message' do
    msg = Message.find(@admin_account, 'AU1fK5QmnuGUxTCvj0lc')
    r = msg.logtrace.first.timestamp - msg.logtrace.last.timestamp
    assert_equal(r, msg.delay)
  end
  
  test 'should raise if account has not jail' do
    assert_raise(Errors::MissingAccountJail) { Message.find(@nojail_account, 'AU1fK5QmnuGUxTCvj0lc') }
  end
  
  test "qid_trace should return a logtrace for the qid" do
    msg = Message.find(@admin_account, 'AU1fK5QmnuGUxTCvj0lc')
    assert_equal(msg.qids.sort, msg.qids_trace.keys.sort) 
  end
  
  test 'relay_qid should return the qid of the relay log' do
    msg = Message.find(@admin_account, 'AU1fK5QmnuGUxTCvj0lc')
    assert_equal(msg.qids_trace.keys.first, msg.relay_qid)
  end
  
  test "processed? should return true if the message has a relay_qid with an qmgr log with result removed" do
    msg = Message.find(@admin_account, 'AU1fK5QmnuGUxTCvj0lc')
    assert(msg.processed?, "Deberia responder true")
    msg.relay_trace.delete_at(0)
    assert(!msg.processed?, "Deberia responder falso")
  end
  
  test "sent_trace should return an array of logs with relay tags and result sent" do
    msg = Message.find(@admin_account, 'AU1fK5QmnuGUxTCvj0lc')
    exp = msg.sent_trace.first
    assert_equal('sent', exp.result)
    assert(exp.tags.include?('relay'), "No tiene el tag relay")
  end
  
  test "bounce_trace should return an array of logs with relay tag and result bounced" do
    msg = Message.find(@admin_account, 'AU1fK5QmnuGUxTCvj0lc')
    assert(msg.bounce_trace.empty?, "No deberia tener bounces.")
    # Estamos cambiando el estado a manito de sent a bounced
    msg.qids_trace[msg.relay_qid][1].data['result'] = ['bounced', 'bounced']
    exp = msg.bounce_trace.first
    assert(exp.result.include?('bounced'), "Deberia tener un bounced")
    msg.qids_trace[msg.relay_qid][1].data['result'] = 'bounced'
    exp = msg.bounce_trace.first
    assert(exp.result.include?('bounced'), "Deberia tener un bounced")
    msg.qids_trace[msg.relay_qid][1].data['component'] = 'bounce'
    assert(msg.bounce_trace.any?, 'Deberia tomar bounce')
  end
  
  test 'deferred_trace should return an array of logs with relay tag and result deferred' do
    msg = Message.find(@admin_account, 'AU1fK5QmnuGUxTCvj0lc')
    assert(msg.deferred_trace.empty?, "No deberia tener deferred.")
    # Estamos cambiando el estado a manito de sent a bounced
    msg.qids_trace[msg.relay_qid][1].data['result'] = ['deferred', 'deferred']
    exp = msg.deferred_trace.first
    assert(exp.result.include?('deferred'), "Deberia tener un deferred")
    msg.qids_trace[msg.relay_qid][1].data['result'] = 'deferred'
    exp = msg.deferred_trace.first
    assert(exp.result.include?('deferred'), "Deberia tener un deferred")
  end
end
