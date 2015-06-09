class DomainsController < ApplicationController
  before_action :set_restriction, only: [:edit, :update, :destroy]
  before_action :validate_admin
  
  def create
    @restriction = Domain.new(domain_params)
    respond_to do |format|
      if @restriction.save
        flash[:notice] = true
        format.html { redirect_to @restriction.account, notice: 'Dominio guardado' }
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
      if @restriction.update(domain_params)
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
  
  def domain_params
    params.require(:domain).permit(:name, :account_id)
  end
  
  def set_restriction
    @restriction = Domain.find(params[:id])
  end
  
end
