class BoxesController < ApplicationController
  before_action :set_box, only: [:show, :edit, :update, :destroy, :assign, :assign_backup, :reassign, :reassign_backup, :delivered, :picked_up, :dropped_off, :received, :open]
  # GET /lockers
  # GET /lockers.json
  def index
    @boxes = Box.all
  end

  # GET /lockers/1
  # GET /lockers/1.json
  def show
    u_packages = Package.where("box_id is NULL and (status = 0 OR status = 5) and status IS NOT NULL").order('updated_at ASC')
    @unassigned_packages = u_packages.select{ |p| 
        if p.preferred_branch_id
          p.preferred_branch_id == @box.branch.id
        elsif p.user.preferred_branch_id
          p.user.preferred_branch_id == @box.branch.id
        else
          true == false
        end 
      }
    @unassigned_packages_for_delivery = @unassigned_packages.select{|p| p.status == '0' }
    @selected_backup_package = @box.backup_package
  end
  
  def open
    respond_to do |format|
      if @box.remote_open
        format.html { redirect_to @box, notice: 'Box is remotely opened.' }
      else
        format.html { redirect_to @box, alert: 'Oops. Something went wrong. Action is not performed.' }
      end
    end
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
        format.html { redirect_to boxes_path, notice: 'Box was successfully created.' }
      else
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /lockers/1
  # PATCH/PUT /lockers/1.json
  def update
    respond_to do |format|
      if @box.update(box_params)
        format.html { redirect_to :back, notice: 'Locker was successfully updated.' }
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
      return false if params[:package_id].nil?
      if params[:package_id] == '' and @box.deliver_package nil
        format.html { redirect_to :back, notice: 'Package assignment was successfully cancelled.' }
      else
        package = Package.find params[:package_id]
        if package.status != @constant['PACKAGE_WAITING_FOR_DELIVERY'].to_i and package.status != @constant['PACKAGE_WAITING_FOR_DROP_OFF'].to_i
          format.html { redirect_to :back, alert: 'Package assign error. Package is already assigned.' }
        elsif @box.package
          format.html { redirect_to :back, alert: 'Package assign error. Box is already occupied' }
        elsif ( (package.status == @constant['PACKAGE_WAITING_FOR_DROP_OFF'].to_i) ? (@box.drop_off_package params[:package_id]) : (@box.deliver_package params[:package_id]) )
          format.html { redirect_to :back, notice: 'Package was successfully assigned.' }
        else
          format.html { redirect_to :back, alert: 'Package assign error.' }
        end
      end
    end
  end
  
  def assign_backup
    respond_to do |format|
      return false if params[:package_id].nil?
      if params[:package_id] == '' and @box.assign_backup_package nil
        format.html { redirect_to :back, notice: 'Package assignment was successfully cancelled.' }
      else
        package = Package.find params[:package_id]
        if package.status != @constant['PACKAGE_WAITING_FOR_DELIVERY'].to_i
          format.html { redirect_to :back, alert: 'Package assign error. Package is not assignable.' }
        elsif @box.backup_package
          format.html { redirect_to :back, alert: 'Package assign error. Box\'s backup queue is already occupied' }
        elsif @box.assign_backup_package params[:package_id]
          format.html { redirect_to :back, notice: 'Package was successfully assigned.' }
        else
          format.html { redirect_to :back, alert: 'Package assign error.' }
        end
      end
    end
  end

  def reassign
    # reassign a package to a new box
    respond_to do |format|
      return false if params[:package_id].nil?
      if params[:package_id] == ''
        format.html { redirect_to :back, alert: 'Package assign error. No package selected.' }
      else
        package = Package.find params[:package_id]
        if package.status != @constant['PACKAGE_ENROUTE_DELIVERY'].to_i and package.status != @constant['PACKAGE_ENROUTE_DROP_OFF'].to_i and package.status != @constant['PACKAGE_QUEUING_DELIVERY'].to_i
          format.html { redirect_to :back, alert: 'Package assign error. Invalid package status.' }
        elsif @box.package
          format.html { redirect_to :back, alert: 'Package assign error. Box is already occupied' }
        elsif ( (package.status == @constant['PACKAGE_ENROUTE_DROP_OFF'].to_i) ? (@box.drop_off_package params[:package_id]) : (@box.deliver_package params[:package_id]) )
          format.html { redirect_to :back, notice: 'Package was successfully reassigned.' }
        else
          format.html { redirect_to :back, alert: 'Package assign error.' }
        end
      end
    end
  end
  
  def reassign_backup
    respond_to do |format|
      return false if params[:package_id].nil?
      if params[:package_id] == ''
        format.html { redirect_to :back, notice: 'Package assign error. No package selected.' }
      else
        package = Package.find params[:package_id]
        if package.status != @constant['PACKAGE_ENROUTE_DELIVERY'].to_i and package.status !=  @constant['PACKAGE_QUEUING_DELIVERY'].to_i 
          format.html { redirect_to :back, alert: 'Package assign error. Invalid package status.' }
        elsif @box.backup_package
          format.html { redirect_to :back, alert: 'Package assign error. Box\'s backup queue is already occupied' }
        elsif @box.assign_backup_package params[:package_id]
          format.html { redirect_to :back, notice: 'Package was successfully reassigned.' }
        else
          format.html { redirect_to :back, alert: 'Package assign error.' }
        end
      end
    end
  end
  
  def delivered
    respond_to do |format|
      if @box.package_delivered
        Logging.log_manual_action @box, @box.package
        format.html { redirect_to :back, notice: 'Package was successfully delivered.' }
      else
        format.html { redirect_to :back, notice: 'Package deliver error.' }
      end
    end
  end
  
  def picked_up
    respond_to do |format|
      package = @box.package
      if @box.package_picked_up
        Logging.log_manual_action @box, package
        format.html { redirect_to :back, notice: 'Package was successfully picked up.' }
      else
        format.html { redirect_to :back, notice: 'Package pick up error.' }
      end
    end
  end
  
  def dropped_off
    respond_to do |format|
      if @box.package_dropped_off
        Logging.log_manual_action @box, @box.package
        format.html { redirect_to :back, notice: 'Package was successfully dropped off.' }
      else
        format.html { redirect_to :back, notice: 'Package drop off error.' }
      end
    end
  end
  
  def received
    respond_to do |format|
      package = @box.package
      if @box.drop_off_package_received
         Logging.log_manual_action @box, package
        format.html { redirect_to :back, notice: 'DropOff package was successfully received.' }
      else
        format.html { redirect_to :back, notice: 'DropOff package was not received.' }
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
