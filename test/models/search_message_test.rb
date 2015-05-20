require 'test_helper'

class SearchMessageTest < ActiveSupport::TestCase

  def setup
    @search  = SearchMessage.new
    @admin = users(:admin)
    @itlinux_user = users(:itlinux_user)
    @zbox_user = users(:zbox_user)
  end

  test 'to_term_filter receive hash and return an array of hash with term key and add raw' do
    look_hash = { 'host' => 'example.com', 'component' => 'cleanup',
                  'from' => 'pbruna@itlinux.cl'
                }
    result = @search.to_term_filter(look_hash)
    result.each do |h|
      assert h['term']
    end
    assert result[0]['term']['host.raw']
  end

  test 'user_scope devuelve la restriccion de busqueda segun usuario' do
    assert(@search.user_scope(@admin).size == 0, 'Admin no deberia tener scope')
    scope_itlinux = @search.user_scope(@itlinux_user)
    scope_zbox = @search.user_scope(@zbox_user)
    assert(scope_itlinux['terms']['host.raw'].include?('server1'), 'No servidor')
    assert(scope_zbox['terms']['from_domain.raw'].include?('x.com'), 'No dominio X')
    assert(scope_zbox['terms']['to_domain.raw'].include?('y.com'), 'No dominio Y')
  end

  test 'set_index_name with nil date should return today index' do
    date = Time.zone.now.to_date.to_s.gsub(/-/, '.')
    result = @search.set_index_name
    assert_equal("logstash-#{date}", result)
  end

  test 'set_index_name with no date object should return today index' do
    date = Time.zone.now.to_date.to_s.gsub(/-/, '.')
    result = @search.set_index_name('2015', nil)
    assert_equal("logstash-#{date}", result)
  end

  test 'set_index_name within same decena should return xxxx.xx.x*' do
    ds = Date.parse('2015-05-11')
    de = Date.parse('2015-05-19')
    result = @search.set_index_name(ds, de)
    assert_equal('logstash-2015.05.1*', result)
  end

  test 'set_index_name within diferent decena should return xxxx.xx.*' do
    ds = Date.parse('2015-05-09')
    de = Date.parse('2015-05-11')
    result = @search.set_index_name(ds, de)
    assert_equal('logstash-2015.05.*', result)
  end

  test 'where should raise ArgumentError if from or to nil' do
    assert_raise(ArgumentError) { @search.where }
  end


end
