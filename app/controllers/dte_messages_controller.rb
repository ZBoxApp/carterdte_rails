class DteMessagesController < ApplicationController
  before_action :set_message, only: [:show, :edit, :update, :destroy]
  skip_before_action :verify_authenticity_token, only: :create

  # GET /messages
  # GET /messages.json
  def index
    params[:q] ||= {}
    params[:q][:account_id_eq] = current_account.id unless current_account.admin?
    @message_search = DteMessage.ransack(params[:q])
    @message_search.sorts = 'sent_date desc'
    @messages = @message_search.result.includes(:dte).page(params[:page])
  end


  # GET /messages/1
  # GET /messages/1.json
  def show
  end

  # GET /messages/new
  def new
    @message = DteMessage.new
  end

  # GET /messages/1/edit
  def edit
  end

  # POST /messages
  # POST /messages.json
  def create
    # We only allow from system type useres
    return head :forbidden unless current_user.system?
    @message = current_account.dte_messages.new(message_params)
    @message.sent_date = Time.parse(message_params[:sent_date]).to_s(:db) unless message_params[:sent_date].nil?
    Rails.logger.debug "AQUI---- #{message_params[:sent_date]} - #{@message.sent_date}"
    respond_to do |format|
      if @message.save
        format.html { redirect_to @message, notice: 'Message was successfully created.' }
        format.json { render :show, status: :created, location: @message }
      else
        format.html { render :new }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /messages/1
  # PATCH/PUT /messages/1.json
  def update
    respond_to do |format|
      if @message.update(message_params)
        format.html { redirect_to @message, notice: 'Message was successfully updated.' }
        format.json { render :show, status: :ok, location: @message }
      else
        format.html { render :edit }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /messages/1
  # DELETE /messages/1.json
  def destroy
    @message.destroy
    respond_to do |format|
      format.html { redirect_to messages_url, notice: 'Message was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = DteMessage.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def message_params
      params.require(:message).permit(:to, :from, :message_id, :cc, :sent_date, :qid, :return_qid, :rut_receptor, :rut_emisor,dte_attributes: [:folio, :rut_receptor, :rut_emisor, :msg_type, :setdte_id, :dte_type, :fecha_emision, :fecha_recepcion, :message_id])
    end
end
