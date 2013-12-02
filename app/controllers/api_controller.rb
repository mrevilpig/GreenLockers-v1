class ApiController < ApplicationController
  def DoorOpened
    return false if !params[:box_id] or !params[:device_id] or !params[:occupied_when_open] or !params[:occupied_when_close] or !params[:type]
    # if params are enough, proceed the request
    @box = Box.where(name: params[:box_id]).select{|b| b.locker.name == params[:device_id]}.first
    #@box = Box.where(name: 'A01').select{|b| b.locker.name == 'UM-01'}.first
    occupied_when_open = params[:occupied_when_open]
    occupied_when_close = params[:occupied_when_close]
    
    constant = YAML.load_file("config/constant.yml")
    #check if the status is error:
    if @box.status == constant['BOX_ERROR'] && !occupied_when_close && params[:type] == constant['DOOR_OPENED_BY_STAFF']
      # if emptied by staff, reset it to IDLE
      @box.status = constant['BOX_IDLE']
      Logging.logAction( params, @box, constant['ACTION_FIX'] )
      return true
    elsif @box.status == constant['BOX_ERROR']
      Logging.logAction( params, @box, constant['ACTION_ERROR'] )
      return false
    end
    
    # check the status change and deal with the change
    if occupied_when_open && occupied_when_close
      #log weird behavior
      Logging.logAction( params, @box, constant['ACTION_WEIRD'] )
      
    elsif !occupied_when_open && !occupied_when_close
      #log weird behavior
      Logging.logAction( params, @box, constant['ACTION_WEIRD'] )
      
    elsif !occupied_when_open && occupied_when_close
      #item put
      if @box.status == constant['BOX_DELIVERING']
        # if the box is assigned and waiting for delivery
        if params[:type] == constant['DOOR_OPENED_BY_PIN']
          @box.status = constant['BOX_ERROR']
          # log error behavior
          Logging.logAction( params, @box, constant['ACTION_ERROR'] )
          return true
        end
        #@box.status = constant['BOX_DELIVERED']
        @box.package_delivered
        # log box delivered (type, staff_id), generate PIN and send to user
        Logging.logAction( params, @box, constant['ACTION_NORMAL'] )
      elsif @box.status == constant['BOX_RETURNING']
        # if the box is assigned for dropoff and waiting for return
        if params[:type] != constant['DOOR_OPENED_BY_PIN']
          @box.status = constant['BOX_ERROR']
          # log error behavior
          Logging.logAction( params, @box, constant['ACTION_ERROR'] )
          return true
        end
        #@box.status = constant['BOX_RETURNED']
        @box.package_dropped_off
        # log box delivered (type, user_id), assign deliverman to pick up
        Logging.logAction( params, @box, constant['ACTION_NORMAL'] )
      else
        # if status doesn't match
        @box.status = constant['BOX_ERROR']
        # log error behavior
        Logging.logAction( params, @box, constant['ACTION_ERROR'] )
        return true
      end
      
    else
      #item taken
      if @box.status == constant['BOX_DELIVERED']
        # if the item is delivered, waiting for user to pickup
        if params[:type] != constant['DOOR_OPENED_BY_PIN']
          # log error behavior
          Logging.logAction( params, @box, constant['ACTION_ERROR'] )
          return true
        end
        #@box.status = constant['BOX_IDLE']
        @box.package_picked_up
        # log item taken by user (type, user_id)
        Logging.logAction( params, @box, constant['ACTION_NORMAL'] )
      elsif @box.status == constant['BOX_RETURNED']
        # if the item is droped off, waiting for deliverman to pickup
        if params[:type] == constant['DOOR_OPENED_BY_PIN']
          @box.status = constant['BOX_ERROR']
          # log error behavior
          Logging.logAction( params, @box, constant['ACTION_ERROR'] )
          return true
        end
        #@box.status = constant['BOX_IDLE']
        @box.drop_off_package_received
        # log item taken by deliverman (type, staff_id)
        Logging.logAction( params, @box, constant['ACTION_NORMAL'] )
      else
        # if status doesn't match
        @box.status = constant['BOX_ERROR']
        # log error behavior
        Logging.logAction( params, @box, constant['ACTION_ERROR'] )
        return true
      end
      
    end
    # if ACTION_NORMAL
    @box.save!
    return true
  end

  def DropOff
    
  end

  def UpdateAccessInfo
    locker = Locker.find_by_name(params[:device_id])
    @accesses = Access.where('box_id in (?) and update_request_id = ?', locker.boxes.collect{|b| b.id}, params[:request_id])
    locker.access_request_id = params[:request_id]
    locker.save!
  end

  def UpdatePermission
    locker = Locker.find_by_name(params[:device_id])
    @permissions = Permission.where('box_id in (?) and update_request_id = ?', locker.boxes.collect{|b| b.id}, params[:request_id]).group_by{|p| p.employee_id}
    locker.permission_request_id = params[:request_id]
    locker.save!
  end
end
