require 'test_helper'


class UserTest < ActiveSupport::TestCase

  def setup
    @admin = users(:admin)
    @system = users(:system)
    @itlinux = accounts(:itlinux)
    @omni_hash = build_omni_hash
  end

  def teardown
    @omni_hash = nil
  end

  test 'should return if an account is system, user' do
    assert(@admin.user?, 'Failure message.')
    assert(@system.system?, 'Failure message.')
  end

  test 'add account_id to new user if account exists' do
    user = User.from_omniauth(@omni_hash)
    assert(user)
    assert_equal(user.zendesk_account_id, 123)
    assert_equal(@itlinux.id, user.account_id, 'No se asigno account_id')
  end

  test 'create account from zendesk if doest not exist and zendesk user' do
    # We are using the ITLinux Zendesk id
    @omni_hash.extra.raw_info.organization_id = 415534
    user = User.from_omniauth(@omni_hash)
    assert(user, 'Deberia haberse creado el usuario')
    account = Account.where(zendesk_id: 415534).first
    assert(account, 'Deberia haberse creado la cuenta')
    assert_equal(user.account.id, account.id)
  end

  test 'should be IT Linux user' do
    # We are using the ITLinux Zendesk id
    @omni_hash.extra.raw_info.organization_id = 415534
    user = User.from_omniauth(@omni_hash)
    assert(user.itlinux?, 'Deberia ser ITLinux')
    assert(!user.zbox_mail?, 'No deberia ser zbox_mail')
    assert(user.admin?, 'Deberia ser admin')
  end

  def build_omni_hash
    OpenStruct.new(
      provider: 'zendesk',
      uid: '9383838',
      info: OpenStruct.new(email: 'pbruna@example.com', name: 'Pato', role:
       OpenStruct.new(name: 'admin')),
      extra: OpenStruct.new(raw_info: OpenStruct.new(organization_id: 123))
      )
  end

end
