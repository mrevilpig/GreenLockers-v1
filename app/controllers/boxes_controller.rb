class BoxesController < ApplicationController
  before_action :set_box, only: [:show, :edit, :update, :destroy, :assign, :delivered, :picked_up]
  layout 'console'
  # GET /lockers
  # GET /lockers.json
  def index
    @boxes = Box.all
  end

  # GET /lockers/1
  # GET /lockers/1.json
  def show
    @unassigned_packages = Package.where("box_id is NULL and (status = 0 OR status = 5)").order('updated_at ASC')
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
      else
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /lockers/1
  # PATCH/PUT /lockers/1.json
  def update
    respond_to do |format|
      if @box.update(locker_params)
        format.html { redirect_to @box, notice: 'Locker was successfully updated.' }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  # DELETE /lockers/1
  # DELETE /lockers/1.json
  def destroy
    @box.destroy
    respond_to do |format|
      format.html { redirect_to boxes_url }
    end
  end
  
  def assign
    respond_to do |format|
      if @box.deliver_package params[:package_id]
        format.html { redirect_to @box, notice: 'Package successfully assigned.' }
      else
        format.html { redirect_to @box, notice: 'Package assign error.' }
      end
    end
  end
  
  def delivered
    respond_to do |format|
      if @box.package_delivered
        format.html { redirect_to @box, notice: 'Package successfully delivered.' }
      else
        format.html { redirect_to @box, notice: 'Package deliver error.' }
      end
    end
  end
  
  def picked_up
    respond_to do |format|
      if @box.package_picked_up
        format.html { redirect_to @box, notice: 'Package successfully picked up.' }
      else
        format.html { redirect_to @box, notice: 'Package pick up error.' }
      end
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
