class MessagesController < ApplicationController

  def index
    redirect_to dte_messages_path if current_account.dte_default?
    begin
      @messages_search = search(params)
      Rails.logger.debug "AQUI---- #{current_account}"
      Rails.logger.debug "ACA---- #{@messages_search.search}"
      @messages = @messages_search.results
    rescue Errors::NoElasticSearchResults => e
      @messages_search = false
      @messages = []
    end
  end

  def show
    @message = Message.find(current_account, params[:id])
  end

  private
  def search(params)
    params = procces_params params
    Message.search(
      account: current_account,
      from: params['from'],
      to: params['to'],
      s_date: params['s_date'],
      e_date: params['e_date'],
      page: params['page'].to_i
    )
  end

  def procces_params(params)
    result = {}
    params.each do |k,v|
      result[k] = v.empty? ? nil : v
    end
    result['s_date'] = Time.zone.parse(result['s_date']).beginning_of_day unless result['s_date'].nil?
    result['e_date'] = Time.zone.parse(result['e_date']).end_of_day unless result['e_date'].nil?
    result
  end

end
