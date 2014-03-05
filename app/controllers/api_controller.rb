class ApiController < ApplicationController
  skip_before_filter  :verify_authenticity_token
  
  def DoorOpened
    # if ACTION_NORMAL
      
    @message = ''
    # check if parameters in post request are sufficient
    if !params[:box_id] or !params[:device_id] or !params[:type] or params[:occupied_when_open].nil? or params[:occupied_when_close].nil? or !params[:timestamp_open] or !params[:timestamp] 
      @message = 'insuffient parameters'
      render json: { :status => false, :message => @message }
      return false
    end

    # if params are enough, proceed the request
    @box = Box.where(name: params[:box_id]).select{|b| b.locker.name == params[:device_id]}.first
    # first check if the box by box_id exists
    if @box.nil?
      @message = 'Box not found'
      render json: { :status => false, :message => @message }
      return false 
    end
    
    occupied_when_open = params[:occupied_when_open]
    occupied_when_close = params[:occupied_when_close]
    
    #check if the status is error:
    if @box.status == @constant['BOX_ERROR'] && !occupied_when_close && params[:timestamp_close] && params[:type] == @constant['DOOR_OPENED_BY_STAFF']
      # if the status is error and the box is emptied by staff, reset it to IDLE (box_fixed)
      @box.status = @constant['BOX_IDLE']
      if @box.save
        Logging.log_action( params, @box, nil, @constant['ACTION_FIX'] )
      end
      return true
    elsif @box.status == @constant['BOX_ERROR']
      # if the status is error but the box is not emptied, return false
      Logging.log_action( params, @box, nil, @constant['ACTION_ERROR'] )
      @message = 'Box error'
      render json: { :status => false, :message => @message }
      return false
    end
    
    # check if the door is closed or not
    if !params[:timestamp_close]
      # if the door is not closed
      t_send = Time.parse(params[:timestamp])
      t_open = Time.parse(params[:timestamp_open])
      Logging.log_action( params, @box, nil, @constant['ACTION_ABNORMAL'] )
      return true
    end
      
    # if the door is closed
    if occupied_when_open && occupied_when_close 
    # check the status change and deal with the change
      #log abnormal behavior
      Logging.log_action( params, @box, nil, @constant['ACTION_ERROR'] )
      
    elsif !occupied_when_open && !occupied_when_close
      #log abnormal behavior
      Logging.log_action( params, @box, nil, @constant['ACTION_ERROR'] )
      
    elsif !occupied_when_open && occupied_when_close
      #item put
      if @box.status == @constant['BOX_DELIVERING']
        # if the box is assigned and waiting to be delivered
        if params[:type] == @constant['DOOR_OPENED_BY_PIN']
          @box.status = @constant['BOX_ERROR']
          # log error behavior
          if @box.save
            Logging.log_action( params, @box, nil, @constant['ACTION_ERROR'] )
          end
          @message = 'Invalid Action'
        else
          package = @box.package.nil? ? nil : @box.package
          if @box.package_delivered
          #@box.status = @constant['BOX_DELIVERED']
            # log box delivered (type, staff_id), generate PIN and send to user
            Logging.log_action( params, @box, package, @constant['ACTION_NORMAL'] )
          end
        end
      elsif @box.status == @constant['BOX_RETURNING']
        # if the box is assigned for dropoff and waiting for return
        if params[:type] != @constant['DOOR_OPENED_BY_PIN']
          @box.status = @constant['BOX_ERROR']
          # log error behavior
          #if @box.save
            Logging.log_action( params, @box, nil, @constant['ACTION_ERROR'] )
          #end
          @message = 'Invalid Action'
        else
          package = @box.package.nil? ? nil : @box.package
          if @box.package_dropped_off
          #@box.status = @constant['BOX_RETURNED']
          # log box delivered (type, user_id), assign deliverman to pick up
            Logging.log_action( params, @box, package, @constant['ACTION_NORMAL'] )
          end
        end
      else
        # if status doesn't match
        @box.status = @constant['BOX_ERROR']
        # log error behavior
        Logging.log_action( params, @box, nil, @constant['ACTION_ERROR'] )
        return true
      end
      
    else
      #item taken
      if @box.status == @constant['BOX_DELIVERED']
        # if the item is delivered, waiting for user to pickup
        if params[:type] != @constant['DOOR_OPENED_BY_PIN']
          @box.status = @constant['BOX_IDLE']
          # log error behavior
          #   -------------------------detach package
          if @box.save
            Logging.log_action( params, @box, nil, @constant['ACTION_ERROR'] )
          end
          @message = 'Invalid Action'
        else
          package = @box.package.nil? ? nil : @box.package
          if @box.package_picked_up
          #@box.status = @constant['BOX_IDLE']
          # log item taken by user (type, user_id)
            Logging.log_action( params, @box, package, @constant['ACTION_NORMAL'] )
          end
        end
      elsif @box.status == @constant['BOX_RETURNED']
        # if the item is droped off, waiting for deliverman to pickup
        if params[:type] == @constant['DOOR_OPENED_BY_PIN']
          @box.status = @constant['BOX_IDLE']
          # log error behavior
          #   -------------------------detach package
          if @box.save
            Logging.log_action( params, @box, nil, @constant['ACTION_ERROR'] )
          end
          @message = 'Invalid Action'
        else
          package = @box.package.nil? ? nil : @box.package
          if @box.drop_off_package_received
          #@box.status = @constant['BOX_IDLE']
          # log item taken by deliverman (type, staff_id)
            Logging.log_action( params, @box, package, @constant['ACTION_NORMAL'] )
          end
        end
      else
        # if status doesn't match
        @box.status = @constant['BOX_IDLE']
        # log error behavior
        if @box.save
          Logging.log_action( params, @box, nil, @constant['ACTION_ERROR'] )
        end
        @message = 'Invalid Action'
      end
      
    end
    
    if @message != ''
      render json: { :status => false, :message => @message }
    elsif @box.save
      render action: 'DoorOpened', status: :success, location: @api
    end
    
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
    @permissions = Permission.where('box_id in (?)', locker.boxes.collect{|b| b.id}).group_by{|p| p.employee_id}
    locker.permission_request_id = params[:request_id]
    locker.save!
    @updates = []
    @permissions.each do |e,perm|
      update = {:staff_id => e.to_s, :box_ids => perm.collect{|p| p.box.name.to_s}}
      @updates.push update
    end
    render json: { :status => true, :updates => @updates }
  end
  
  def BarcodeNotExist
    
  end
end
