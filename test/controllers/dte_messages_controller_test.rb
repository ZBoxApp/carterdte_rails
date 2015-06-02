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
  
  test 'it should the correct values for the fields' do
    hash = {"to"=>"gascoglp@facturanet.cl","from"=>"dte_vsp@xs6dte.cl","qid"=>"8C462753E09","message_id"=>"10282147.1433272626715.JavaMail.tomcat@xs4ccu00204.xs4dte.cl","cc"=>nil,"sent_date"=>"2015-06-02T16:17:06-03:00","return_qid"=>"E41A22EC0F0","dte_attributes"=>{"folio"=>"7683446","rut_receptor"=>"91041000-8","rut_emisor"=>"96568740-8","msg_type"=>"respuesta","setdte_id"=>"SETDTE96568740X33X7683446X95591927","dte_type"=>"33","fecha_emision"=>"2015-05-29","fecha_recepcion"=>"2015-06-02"}}
    sign_in @system
    post :create, message: hash, format: :json
    message = assigns(:message)
    assert_equal(Time.zone.parse(hash['sent_date']), message.sent_date)
    assert_equal(Date.parse(hash['dte_attributes']['fecha_emision']), message.dte.fecha_emision)
    assert_equal(Date.parse(hash['dte_attributes']['fecha_recepcion']), message.dte.fecha_recepcion)
  end



end
