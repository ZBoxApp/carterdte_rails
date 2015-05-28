require 'test_helper'

class AccountTest < ActiveSupport::TestCase

  # Estamos usando Asoex como ejemplo
  test 'Should get account info from Zendesk app' do
    zacc = Account.get_info_from_zendesk(26822021)
    assert_equal(zacc[:name], 'Asoex')
    assert_equal(zacc[:zbox_mail], true)
    assert_equal(zacc[:zendesk_id], 26822021)
  end

  test 'New from Zendesk info should save the account' do
    zacc = Account.get_info_from_zendesk(26822021)
    account = Account.new(zacc)
    assert(account.save, "Deberia salvarla")
    assert(account.zbox_mail?)
    assert(!account.itlinux?)
  end

  test 'admin? shoul return true if the account has an admin user' do
    admin = accounts(:itlinux)
    noadmin = accounts(:zbox_client)
    assert(admin.admin?, 'Tiene que ser admin')
    assert(!noadmin.admin?, 'No tiene que ser admin')
  end

  test 'when admin jail should return false' do
    account = accounts(:itlinux)
    assert !account.jail, 'No tiene que estar enjaulado'
  end

  test 'zbox jail return a hash with keys from_domain and to_domain' do
    account = accounts(:zbox_client)
    jail = account.jail
    assert jail.is_a?(Array), "from_domain tiene que ser Array"
    assert_equal (account.domains.size * 2), jail.size
  end

  test 'itlinux jail return a hash with servers' do
    account = accounts(:itlinux_client)
    jail = account.jail
    assert jail.is_a?(Array), "hosts tiene que ser Array"
    jail.each do |h|
      assert account.servers.map(&:name).include?(h['host'])
    end
  end

end
