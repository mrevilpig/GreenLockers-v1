class EmployeesController < ApplicationController
  before_action :set_employee, only: [:show, :edit, :update, :destroy, :set_permissions, :set_privileges]
  # GET /employees
  # GET /employees.json
  def index
    @employees = Employee.all
  end

  # GET /employees/1
  # GET /employees/1.json
  def show
    @boxes = Box.all
    @lockers = Locker.all
  end

  # GET /employees/new
  def new
    @employee = Employee.new
  end

  # GET /employees/1/edit
  def edit
  end

  # POST /employees
  # POST /employees.json
  def create
    @employee = Employee.new(employee_params)

    respond_to do |format|
      if @employee.save
        format.html { redirect_to @employee, notice: 'Employee was successfully created.' }
        format.json { render action: 'show', status: :created, location: @employee }
      else
        format.html { render action: 'new' }
        format.json { render json: @employee.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /employees/1
  # PATCH/PUT /employees/1.json
  def update
    respond_to do |format|
      if @employee.update(employee_params)
        format.html { redirect_to @employee, notice: 'Employee was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @employee.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /employees/1
  # DELETE /employees/1.json
  def destroy
    @employee.destroy
    respond_to do |format|
      format.html { redirect_to employees_url }
      format.json { head :no_content }
    end
  end
  
  def set_permissions
    respond_to do |format|
      old_boxes = @employee.permissions.collect{|p| p.box_id}
      @employee.permissions.destroy_all
      boxes = params[:boxes]
      boxes.delete_at(0)
      boxes.each do |b|
        box = Box.find(b.to_i)
        #logger.info box.locker.name
        p = Permission.new(employee_id: params[:id].to_i, box_id: b.to_i, update_request_id: (box.locker.permission_request_id + 1))
        p.save!
      end
      new_boxes = boxes.collect{|i| i.to_i}
      # to figure out which devices to notice and which not
      new_lockers = {}
      new_boxes.each do |b|
        box = Box.find b
        if box.status == @constant['BOX_RETURNED'] and new_lockers[box.locker.name].nil?
          new_lockers[box.locker.name] = [box.name]
        elsif box.status == @constant['BOX_RETURNED']
          new_lockers[box.locker.name].push box.name
        end
      end
      #logger.info new_lockers
      old_lockers = {}
      old_boxes.each do |b|
        box = Box.find b
        if box.status == @constant['BOX_RETURNED'] and old_lockers[box.locker.name].nil?
          old_lockers[box.locker.name] = [box.name]
        elsif box.status == @constant['BOX_RETURNED']
          old_lockers[box.locker.name].push box.name
        end
      end
      #logger.info old_lockers
      old_lockers.each do |l,b|
        if new_lockers[l].nil?
          @employee.remove_operator_info l
        end
      end
      changed = {}
      new_lockers.each do |l,b|
        if old_lockers[l].nil?
          @employee.push_operator_info l, b
        elsif old_lockers[l] - new_lockers[l] != [] or new_lockers[l] - old_lockers[l] != []
          @employee.push_operator_info l, b
        end
      end

      
      #if .package_dropped_off
      format.html { redirect_to @employee, notice: 'Permissions successfully set.' }
      #else
      #  format.html { redirect_to @box, notice: 'Package drop off error.' }
      #end
    end
  end
  
  def set_privileges
    respond_to do |format|
      old_lockers = @employee.privileges.collect{|p| p.locker_id}
      @employee.privileges.destroy_all
      lockers = params[:lockers]
      lockers.delete_at(0)
      lockers.each do |l|
        locker = Locker.find(l.to_i)
        #logger.info locker.name
        p = Privilege.new(employee_id: params[:id].to_i, locker_id: l.to_i)
        p.save!
      end
      new_lockers = lockers.collect{|i| i.to_i}
      (old_lockers - new_lockers).each do |l|
        locker = Locker.find l
        @employee.remove_admin_info locker.name
      end
      (new_lockers - old_lockers).each do |l|
        locker = Locker.find l
        @employee.push_admin_info locker.name
      end
      format.html { redirect_to @employee, notice: 'Privileges successfully set.' }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_employee
      @employee = Employee.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def employee_params
      params.require(:employee).permit(:first_name, :last_name, :middle_name, :mobile_phone, :email, :user_name, :role, :password)
    end
end
