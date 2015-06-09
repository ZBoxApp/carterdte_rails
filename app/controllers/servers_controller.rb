class ServersController < ApplicationController  
  before_action :set_restriction, only: [:edit, :update, :destroy]
  before_action :validate_admin
  
  def create
    @restriction = Server.new(server_params)
    respond_to do |format|
      if @restriction.save
        flash[:notice] = true
        format.html { redirect_to @restriction.account, notice: 'Servidor guardado' }
        # format.json { render :show, status: :created, location: @message }
      else
        flash[:error] = true
        format.html { redirect_to @restriction.account }
        # format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def update
    respond_to do |format|
      if @restriction.update(server_params)
        flash[:notice] = true
        format.html { redirect_to @restriction.account, notice: 'Servidor guardado' }
        # format.json { render :show, status: :created, location: @message }
      else
        flash[:error] = true
        format.html { redirect_to @restriction.account }
        # format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def destroy
    respond_to do |format|
      if @restriction.destroy
        flash[:notice] = true
        format.html { redirect_to @restriction.account, notice: 'Servidor guardado' }
        # format.json { render :show, status: :created, location: @message }
      else
        flash[:error] = true
        format.html { redirect_to @restriction.account }
        # format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end
  
  private
  def validate_admin
    return head :forbidden unless current_account.admin?
  end
  
  def server_params
    params.require(:server).permit(:name, :account_id)
  end
  
  def set_restriction
    @restriction = Server.find(params[:id])
  end
  
end
