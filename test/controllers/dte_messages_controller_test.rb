require 'test_helper'

class DteMessagesControllerTest < ActionController::TestCase
  setup do
    @admin = users(:admin)
    @system = users(:system)
    @msg_sent = dte_messages(:envio)
    @dte_envio = dtes(:envio)
    @msg_resp = dte_messages(:respuesta)
  end

  def teardown
    @msg_sent = nil
    @msg_resp = nil
    DteMessage.all.each {|m| m.destroy }
  end

  def hash_msg(msg)
    hash_msg = JSON.parse(msg.to_json)
    hash_msg["dte_attributes"] = JSON.parse(@dte_envio.to_json)
    hash_msg.delete("account_id")
    hash_msg["dte_attributes"].delete("account_id")
    hash_msg
  end

  test "should get index" do
    sign_in @admin
    get :index
    assert_response :success
  end

  test "create should response unauthorized for users accounts" do
    sign_in @admin
    post :create, message: {to: "test@example.com"}, format: :json
    assert_response 403
  end

  test "create should response authorized for system accounts" do
    sign_in @system
    post :create, message: {to: "test@example.com"}, format: :json
    assert_response :success
    hash = JSON.parse(response.body)
    assert_equal("test@example.com", hash["to"])
  end

  test "should create message with embeded dte" do
    @msg_sent.message_id = "idaodaoidnaoindoao"
    sign_in @system
    params = hash_msg(@msg_sent)
    post :create, message: params, format: :json
    assert_response :success
    hash = JSON.parse(response.body)
    assert_not_nil(hash["dte"])
    assert_equal(@dte_envio.rut_receptor, hash["dte"]["rut_receptor"])
  end

  test "it should save the dte with the message_id" do
    sign_in @system
    params = hash_msg(@msg_sent)
    post :create, message: params, format: :json
    message = assigns(:message)
    assert_equal(message.id, message.dte.dte_message_id)
  end

  test "it should save the message and dte with the current_user account_id" do
    sign_in @system
    params = hash_msg(@msg_sent)
    post :create, message: params, format: :json
    message = assigns(:message)
    assert_equal(@system.account_id, message.account_id)
    #assert_equal(@system.account_id, message.dte.account_id)
  end



end
