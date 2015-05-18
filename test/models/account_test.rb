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

end
