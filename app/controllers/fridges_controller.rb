class FridgesController < ApplicationController
  before_action :authenticate_user!, except: [:inbound]
  skip_before_action :verify_authenticity_token, only: [:inbound]

  before_action :set_fridge, only: [:show, :edit, :update, :destroy]

  # GET /fridges
  # GET /fridges.json
  def index
    @fridges = current_user.fridges
  end

  # GET /fridges/1
  # GET /fridges/1.json
  def show
  end

  # GET /fridges/new
  def new
    @fridge = current_user.fridges.new
  end

  # GET /fridges/1/edit
  def edit
  end

  # POST /fridges
  # POST /fridges.json
  def create
    @fridge = current_user.fridges.new(fridge_params)

    respond_to do |format|
      if @fridge.save
        format.html { redirect_to kitchen_board_path, notice: t('activerecord.flash.created', model: @fridge.name) }
        format.json { render action: 'show', status: :created, location: kitchen_board_path }
      else
        format.html { render action: 'new' }
        format.json { render json: @fridge.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /fridges/1
  # PATCH/PUT /fridges/1.json
  def update
    respond_to do |format|
      if @fridge.update(fridge_params)
        format.html { redirect_to kitchen_board_path, notice: t('activerecord.flash.updated', model: @fridge.name) }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @fridge.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /fridges/1
  # DELETE /fridges/1.json
  def destroy
    @fridge.destroy
    respond_to do |format|
      format.html { redirect_to kitchen_board_path, notice: t('activerecord.flash.deleted', model: @fridge.name) }
      format.json { head :no_content }
    end
  end

  def inbound
    if params[:mandrill_events]
      token, foods = Fridge.parse_inbound_data(params[:mandrill_events])
      if @fridge = Fridge.where(inbound_token: token).first
        foods.each do |name, deadline|
          @fridge.foods.create name: name, deadline: deadline
        end
      end
      render text: 'success'
    else
      raise
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_fridge
    @fridge = current_user.fridges.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def fridge_params
    params.require(:fridge).permit(:name)
  end
end
