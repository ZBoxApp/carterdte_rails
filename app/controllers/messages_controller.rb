class MessagesController < ApplicationController

  def index
    @messages_search = search(params)
    @messages = @messages_search.results
  end

  def show
    @message = Message.find(current_account, params[:id])
  end

  private
  def search(params)
    params = procces_params params
    Rails.logger.debug "AQUI....#{params}"
    Message.search(
      account: current_account,
      from: params['from'],
      to: params['to'],
      s_date: params['s_date'],
      e_date: params['e_date'],
    )
  end

  def procces_params(params)
    result = {}
    params.each do |k,v|
      result[k] = v.empty? ? nil : v
    end
    result
  end

end
