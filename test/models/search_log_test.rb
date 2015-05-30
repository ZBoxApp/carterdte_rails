require 'test_helper'

class SearchLogTest < ActiveSupport::TestCase

  def setup
    query = SearchLogQuery.amavisd_by_emails
    @search  = SearchLog.new(query: query)
    @admin = users(:admin)
    @itlinux_user = users(:itlinux_user)
    @zbox_user = users(:zbox_user)
  end

  test 'to_term_filter receive hash and return an array of hash with term key and add raw' do
    look_hash = { 'host' => 'example.com', 'component' => 'cleanup',
                  'from' => 'pbruna@itlinux.cl',
                  'to' => nil
                }
    result = @search.to_term_filter(look_hash)
    result.each do |h|
      assert h['term'].values.first
    end
    assert result[0]['term']['host.raw']
  end

  # test 'set_index_name with nil date should return today index' do
  #   date = Time.zone.now.to_date.to_s.gsub(/-/, '.')
  #   result = @search.set_index_name
  #   assert_equal("logstash-#{date}", result)
  # end

  # test 'set_index_name within same decena should return xxxx.xx.x*' do
  #   s_date = Date.parse('2015-05-11')
  #   e_date = Date.parse('2015-05-19')
  #   @search.set_dates(s_date, e_date)
  #   result = @search.set_index_name
  #   assert_equal('logstash-2015.05.1*', result)
  # end
  #
  # test 'set_index_name within diferent decena should return xxxx.xx.*' do
  #   s_date = Date.parse('2015-05-09')
  #   e_date = Date.parse('2015-05-11')
  #   @search.set_dates(s_date, e_date)
  #   result = @search.set_index_name
  #   assert_equal('logstash-2015.05.*', result)
  # end

  test 'date_range_filter should set date for the valid date if one is nil' do
    date = Time.zone.now.to_date
    @search.set_dates(nil, date)
    result = @search.date_range_filter
    assert_equal date.to_s, result['@timestamp']['gte'].to_s
    assert_equal date.to_s, result['@timestamp']['lte'].to_s
  end

  # test 'date_range_filter if both date are nil set date for Today' do
  #   date = Time.zone.now.to_date
  #   result = @search.date_range_filter
  #   assert_equal date.to_s, result['@timestamp']['gte'].to_s
  #   assert_equal date.to_s, result['@timestamp']['lte'].to_s
  # end

  test 'jail_filter for admin should return an empty array' do
    @search.jail = @admin.account.jail
    assert_equal [], @search.jail_filter
  end

  test 'jail for itlinux should return array with servers' do
    @search.jail = @itlinux_user.account.jail
    servers_names = @itlinux_user.account.servers.map(&:name)
    @search.jail_filter.each do |h|
      assert servers_names.include?(h['term']['host.raw'])
    end
  end

  test 'jail for zbox_mail should return array with domain' do
    @search.jail = @zbox_user.account.jail
    domains_names = @zbox_user.account.domains.map(&:name)
    assert_equal((domains_names.size * 2), @search.jail_filter.size)
    sample = @search.jail_filter.map { |r| r['term'].values.first }
    assert_equal domains_names.sort, sample.uniq.sort
  end

end
