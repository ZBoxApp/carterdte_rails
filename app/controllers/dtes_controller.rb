class DtesController < ApplicationController
  before_action :set_dte, only: [:show, :edit, :update, :destroy]

  # GET /dtes
  # GET /dtes.json
  def index
    @dtes = Dte.all
  end

  # GET /dtes/1
  # GET /dtes/1.json
  def show
  end

  # GET /dtes/new
  def new
    @dte = Dte.new
  end

  # GET /dtes/1/edit
  def edit
  end

  # POST /dtes
  # POST /dtes.json
  def create
    @dte = Dte.new(dte_params)

    respond_to do |format|
      if @dte.save
        format.html { redirect_to @dte, notice: 'Dte was successfully created.' }
        format.json { render :show, status: :created, location: @dte }
      else
        format.html { render :new }
        format.json { render json: @dte.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /dtes/1
  # PATCH/PUT /dtes/1.json
  def update
    respond_to do |format|
      if @dte.update(dte_params)
        format.html { redirect_to @dte, notice: 'Dte was successfully updated.' }
        format.json { render :show, status: :ok, location: @dte }
      else
        format.html { render :edit }
        format.json { render json: @dte.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dtes/1
  # DELETE /dtes/1.json
  def destroy
    @dte.destroy
    respond_to do |format|
      format.html { redirect_to dtes_url, notice: 'Dte was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dte
      @dte = Dte.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def dte_params
      params.require(:dte).permit(:folio, :rut_receptor, :rut_emisor, :msg_type, :setdte_id, :dte_type, :fecha_emision, :fecha_recepcion, :account_id, :message_id)
    end
end
