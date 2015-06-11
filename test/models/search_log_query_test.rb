require 'test_helper'

class SearchLogQueryTest < ActiveSupport::TestCase
  
  test "amavis_by_emails debe funcionar con dominios" do
    query = SearchLogQuery.amavisd_by_emails(from: 'zimbra.com', to: 'pbruna@itlinux.cl')
    assert_equal('from_domain', query[2].keys.first)
    assert_equal('zimbra.com', query[2].values.first)
    assert_equal('pbruna@itlinux.cl', query[3].values.first)
  end
  
  test 'is_email? should check if is an email' do
    assert(SearchLogQuery.is_email?('pbruna@itlinux.cl'), "Deberia ser verdadero")
    assert(!SearchLogQuery.is_email?('pbruna'), "No Deberia ser verdadero")
    assert(SearchLogQuery.is_email?('pbruna@itlinux.cl.gi'), "Deberia ser verdadero")
    assert(!SearchLogQuery.is_email?('pbruna.itlinux.cl'), "No Deberia ser verdadero")
  end
  
end
