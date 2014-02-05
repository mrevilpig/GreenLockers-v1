class ApiController < ApplicationController
  skip_before_filter  :verify_authenticity_token
  
  def DoorOpened
    # if ACTION_NORMAL
      
    @message = ''
    if !params[:box_id] or !params[:device_id] or params[:occupied_when_open].nil? or params[:occupied_when_close].nil? or !params[:type]
      @message = 'insuffient parameters'
      render action: 'error', status: :error, location: @api
      return false 
    end
    # if params are enough, proceed the request
    @box = Box.where(name: params[:box_id]).select{|b| b.locker.name == params[:device_id]}.first
    if @box.nil?
      @message = 'box not found'
      render action: 'error', status: :error, location: @api
      return false 
    end
    
    #@box = Box.where(name: 'A01').select{|b| b.locker.name == 'UM-01'}.first
    occupied_when_open = params[:occupied_when_open]
    occupied_when_close = params[:occupied_when_close]
    
    #check if the status is error:
    if @box.status == @constant['BOX_ERROR'] && !occupied_when_close && params[:type] == @constant['DOOR_OPENED_BY_STAFF']
      # if emptied by staff, reset it to IDLE
      @box.status = @constant['BOX_IDLE']
      if box.save
        Logging.log_action( params, @box, @constant['ACTION_FIX'] )
      end
      render action: 'DoorOpened', status: :success, location: @api
      return true
    elsif @box.status == @constant['BOX_ERROR']
      Logging.log_action( params, @box, @constant['ACTION_ERROR'] )
      @message = 'Box error'
      render action: 'error', status: :error, location: @api
      return false
    end
    
    if occupied_when_open && occupied_when_close 
    # check the status change and deal with the change
      #log weird behavior
      Logging.log_action( params, @box, @constant['ACTION_WEIRD'] )
      
    elsif !occupied_when_open && !occupied_when_close
      #log weird behavior
      Logging.log_action( params, @box, @constant['ACTION_WEIRD'] )
      
    elsif !occupied_when_open && occupied_when_close
      #item put
      if @box.status == @constant['BOX_DELIVERING']
        # if the box is assigned and waiting for delivery
        if params[:type] == @constant['DOOR_OPENED_BY_PIN']
          @box.status = @constant['BOX_ERROR']
          # log error behavior
          if @box.save
            Logging.log_action( params, @box, @constant['ACTION_ERROR'] )
          end
          @message = 'Invalid Action'
        elsif @box.package_delivered
        #@box.status = @constant['BOX_DELIVERED']
          # log box delivered (type, staff_id), generate PIN and send to user
          Logging.log_action( params, @box, @constant['ACTION_NORMAL'] )
        end
      elsif @box.status == @constant['BOX_RETURNING']
        # if the box is assigned for dropoff and waiting for return
        if params[:type] != @constant['DOOR_OPENED_BY_PIN']
          @box.status = @constant['BOX_ERROR']
          # log error behavior
          if @box.save
            Logging.log_action( params, @box, @constant['ACTION_ERROR'] )
          end
          @message = 'Invalid Action'
        elsif @box.package_dropped_off
        #@box.status = @constant['BOX_RETURNED']
        # log box delivered (type, user_id), assign deliverman to pick up
          Logging.log_action( params, @box, @constant['ACTION_NORMAL'] )
        end
      else
        # if status doesn't match
        @box.status = @constant['BOX_ERROR']
        # log error behavior
        Logging.log_action( params, @box, @constant['ACTION_ERROR'] )
        return true
      end
      
    else
      #item taken
      if @box.status == @constant['BOX_DELIVERED']
        # if the item is delivered, waiting for user to pickup
        if params[:type] != @constant['DOOR_OPENED_BY_PIN']
          @box.status = @constant['BOX_ERROR']
          # log error behavior
          if @box.save
            Logging.log_action( params, @box, @constant['ACTION_ERROR'] )
          end
          @message = 'Invalid Action'
        elsif @box.package_picked_up
        #@box.status = @constant['BOX_IDLE']
        # log item taken by user (type, user_id)
          Logging.log_action( params, @box, @constant['ACTION_NORMAL'] )
        end
      elsif @box.status == @constant['BOX_RETURNED']
        # if the item is droped off, waiting for deliverman to pickup
        if params[:type] == @constant['DOOR_OPENED_BY_PIN']
          @box.status = @constant['BOX_ERROR']
          # log error behavior
          if @box.save
            Logging.log_action( params, @box, @constant['ACTION_ERROR'] )
          end
          @message = 'Invalid Action'
        elsif @box.drop_off_package_received
        #@box.status = @constant['BOX_IDLE']
        # log item taken by deliverman (type, staff_id)
          Logging.log_action( params, @box, @constant['ACTION_NORMAL'] )
        end
      else
        # if status doesn't match
        @box.status = @constant['BOX_ERROR']
        # log error behavior
        if @box.save
          Logging.log_action( params, @box, @constant['ACTION_ERROR'] )
        end
        @message = 'Invalid Action'
      end
      
    end
    
    if @message != ''
      render action: 'error', status: :error, location: @api
    elsif @box.save
      render action: 'DoorOpened', status: :success, location: @api
    end

    
    return true
  end

  def DropOff
    
  end

  def UpdateAccessInfo
    locker = Locker.find_by_name(params[:device_id])
    @accesses = Access.where('box_id in (?) and update_request_id = ?', locker.boxes.collect{|b| b.id}, params[:request_id])
    logger.info @accesses
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
