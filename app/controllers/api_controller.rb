class ApiController < ApplicationController
  def DoorOpened
    if !params[:box_id] or !params[:device_id] or !params[:occupied_when_open] or !params[:occupied_when_close] or !params[:type]
      return false
    # if params are enough, proceed the request
    @box = Box.where(name: params[:box_id]).select{|b| b.locker.name == params[:device_id]}.first
    #@box = Box.where(name: 'A01').select{|b| b.locker.name == 'UM-01'}.first
    occupied_when_open = params[:occupied_when_open]
    occupied_when_close = params[:occupied_when_close]
    
    #check if the status is error:
    if @box.status == BOX_ERROR && !occupied_when_close && params[:type] == DOOR_OPENED_BY_STAFF
      # if emptied by staff, reset it to IDLE
      @box.status = BOX_IDLE
      return true
    elsif @box.status == BOX_ERROR
      return false
    end
    
    # check the status change and deal with the change
    if occupied_when_open && occupied_when_close
      #log weird behavior
    elsif !occupied_when_open && !occupied_when_close
      #log weird behavior
    elsif !occupied_when_open && occupied_when_close
      #item put
      if @box.status == BOX_DELIVERING
        # if the box is assigned and waiting for delivery
        if params[:type] == DOOR_OPENED_BY_PIN
          # log error behavior
          return true
        end
        @box.status = BOX_DELIVERED
        # log box delivered (type, staff_id), generate PIN and send to user
      elsif @box.status == BOX_RETURNING
        # if the box is assigned for dropoff and waiting for return
        if params[:type] != DOOR_OPENED_BY_PIN
          # log error behavior
          return true
        end
        @box.status = BOX_RETURNED
        # log box delivered (type, user_id), assign deliverman to pick up
      else
        # if status doesn't match
        @box.status = BOX_ERROR
        # log error behavior
        return true
      end
    else
      #item taken
      if @box.status == BOX_DELIVERED
        # if the item is delivered, waiting for user to pickup
        if params[:type] != DOOR_OPENED_BY_PIN
          # log error behavior
          return true
        end
        @box.status = BOX_IDLE
        # log item taken by user (type, user_id)
      elsif @box.status = BOX_RETURNED
        # if the item is droped off, waiting for deliverman to pickup
        if params[:type] == DOOR_OPENED_BY_PIN
          # log error behavior
          return true
        end
        @box.status = BOX_IDLE
        # log item taken by deliverman (type, staff_id)
      else
        # if status doesn't match
        @box.status = BOX_ERROR
        # log error behavior
        return true
      end
    end
    # if box is assigned
    @box.save!
    return true
  end

  def DropOff
  end

  def UpdateAccessInfo
  end

  def UpdatePermission
  end
end
