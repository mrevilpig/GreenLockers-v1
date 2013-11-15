class BoxesController < ApplicationController
  before_action :set_box, only: [:show, :edit, :update, :destroy]

  # GET /lockers
  # GET /lockers.json
  def index
    @boxes = Box.all
  end

  # GET /lockers/1
  # GET /lockers/1.json
  def show
  end

  # GET /lockers/new
  def new
    @box = Box.new
  end

  # GET /lockers/1/edit
  def edit
  end

  # POST /lockers
  # POST /lockers.json
  def create
    @box = Box.new(box_params)

    respond_to do |format|
      if @box.save
        format.html { redirect_to @box, notice: 'Locker was successfully created.' }
        format.json { render action: 'show', status: :created, location: @box }
      else
        format.html { render action: 'new' }
        format.json { render json: @box.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /lockers/1
  # PATCH/PUT /lockers/1.json
  def update
    respond_to do |format|
      if @box.update(locker_params)
        format.html { redirect_to @box, notice: 'Locker was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @box.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lockers/1
  # DELETE /lockers/1.json
  def destroy
    @box.destroy
    respond_to do |format|
      format.html { redirect_to boxes_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_box
      @box = Box.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def box_params
      params.require(:box).permit(:locker_id, :name, :size, :status)
    end
end
