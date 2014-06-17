class Logging < ActiveRecord::Base
  belongs_to :box
  belongs_to :employee
  belongs_to :package
  CONSTANT = YAML.load_file("#{Rails.root}/config/constant.yml")
  
  def self.log_action params, box, package, action_type
    owo = params[:occupied_when_open] ? 1:0
    owc = params[:occupied_when_close] ? 1:0
    to = params[:timestamp_open].nil? ? nil : Time.parse(params[:timestamp_open]) 
    tc = params[:timestamp_close].nil? ? nil : Time.parse(params[:timestamp_close])
    eid = params[:staff_id].nil? ? nil : params[:staff_id].to_i
    if action_type == CONSTANT['ACTION_FIX']
      stype = CONSTANT['SYNTAX_BOX_FIX']
    else
      stype = CONSTANT['SYNTAX_BOX_ACTION']
    end
    if package.nil?
      package = box.package
    end
    pid = package.nil? ? nil : package.id
    pstatus = package.nil? ? nil : package.status
    t = Time.parse(params[:timestamp])
    p = {
                open_time: to, close_time: tc, request_time: t,
                employee_id: eid, log_type: params[:type], box_id: box.id, box_status: box.status, 
                package_id: pid, package_status: pstatus, syntax_type: stype,
                occupied_when_open: owo, occupied_when_close: owc, action_type: action_type
    }
    @logging = Logging.new(p)
    @logging.save!
  end
  
  def self.log_manual_action box, package
    return false if package.nil?
    t = Time.now
    case package.status
    when CONSTANT['PACKAGE_WAITING_FOR_DELIVERY'].to_i, CONSTANT['PACKAGE_WAITING_FOR_DROP_OFF'].to_i
      if box.nil?
        #creation
        stype = CONSTANT['SYNTAX_PACKAGE_CREATE']
        owo = false
        owc = false
        bid = nil
        bstatus = nil
      else
        #creation
        stype = CONSTANT['SYNTAX_PACKAGE_RESET']
        owo = false
        owc = false
        bid = box.id
        bstatus = box.status
      end
    when CONSTANT['PACKAGE_ENROUTE_DELIVERY'].to_i, CONSTANT['PACKAGE_ENROUTE_DROP_OFF'].to_i
      #assign
      stype = CONSTANT['SYNTAX_PACKAGE_ASSIGN']
      owo = false
      owc = false
      bid = box.id
      bstatus = box.status
    when CONSTANT['PACKAGE_DELIVERED_DELIVERY'].to_i, CONSTANT['PACKAGE_DROPPED_OFF_DROP_OFF'].to_i
      #drop off
      stype = CONSTANT['SYNTAX_BOX_MANUAL_ACTION']
      owo = false
      owc = true
      bid = box.id
      bstatus = box.status
    when CONSTANT['PACKAGE_DONE_DELIVERY'].to_i, CONSTANT['PACKAGE_DONE_DROP_OFF'].to_i
      #pick up
      stype = CONSTANT['SYNTAX_BOX_MANUAL_ACTION']
      owo = true
      owc = false
      bid = box.id
      bstatus = box.status
    when CONSTANT['PACKAGE_QUEUING_DELIVERY'].to_i
      #queue
      stype = CONSTANT['SYNTAX_PACKAGE_ASSIGN_BACKUP']
      owo = false
      owc = false
      bid = box.id
      bstatus = box.status
    when nil
      #destroyed
      stype = CONSTANT['SYNTAX_PACKAGE_DESTROYED']
      owo = false
      owc = false
      bid = nil
      bstatus = nil
    else
      return false
    end
    to = nil
    tc = nil
    # employee_id should be set to the operator who makes the change, here we set it to zero temprorily
    eid = 0
    pid = package.id
    pstatus = package.status
    p = {
                open_time: to, close_time: tc, request_time: t,
                employee_id: eid, log_type: CONSTANT['LOG_TYPE_MANUAL'], box_id: bid, box_status: bstatus, 
                package_id: pid, package_status: pstatus, syntax_type: stype,
                occupied_when_open: owo, occupied_when_close: owc, action_type: CONSTANT['ACTION_MANUAL']
    }
    logger.info p
    @logging = Logging.new(p)
    @logging.save!
  end
  
  def show_access_method
    case self.log_type
    when 0
      return "Pin" 
    when 1
      return "Barcode"
    when 2
      return "Permission"
    when 9
      return "Server"
    else
      return "Unknown"
    end
  end
  
  def show_action_type
    case self.action_type
    when 0
      return "Normal" 
    when 1
      return "Abnormal"
    when 2
      return "Error"
    when 3
      return "Fix"
    when 4
      return "Manual"
    else
      return "Unknown"
    end
  end
  
  def print_package_status
    case self.package_status
    when 0
      return "Delivery - New"
    when 1
      return "Delivery - En Route" 
    when 2
      return "Delivery - Delivered" 
    when 3
      return "Delivery - Done"
    when 4
      return "Delivery - Queuing"
    when 5
      return "DropOff - New"
    when 6
      return "DropOff - En Route"
    when 7
      return "DropOff - Dropped off"
    when 8
      return "DropOff - Done"
    when nil
      return "No Package"
    else
      return "Unknown"
    end
  end
  
  def print_sentence
    case self.syntax_type
    when CONSTANT['SYNTAX_BOX_ACTION']
      type = self.print_package_status
      box = self.box.locker.name + '-' + self.box.name
      if self.log_type == '0'
        person = 'user '+ self.box.user.user_name
      elsif self.employee
        person = 'staff '+ self.employee.user_name
      else
        person = 'unknown user'
      end
      time_open = self.open_time
      if self.close_time
        close_clause = "and closed"
      else
        duration = self.request_time - self.open_time
        close_clause = "but not closed in #{duration.to_s} seconds."
      end
      sentence = "[#{type}] Box #{box} was opened by #{person} #{close_clause}. "
      if self.package
        barcode = self.package.barcode
        owo = self.occupied_when_open
        owc = self.occupied_when_close
        if owo
          action = 'picked up'
        else
          action = 'dropped off'
        end
        if owo == owc
          bool = 'not '
        else
          bool = ''
        end
        package_sentence = "Package #{barcode} was #{bool}#{action}."
        sentence = sentence + package_sentence
      end
      
      return sentence
    when CONSTANT['SYNTAX_BOX_MANUAL_ACTION']
      type = self.print_package_status
      box = self.box.locker.name + '-' + self.box.name
      barcode = self.package.barcode
      owo = self.occupied_when_open
      owc = self.occupied_when_close
      if owo
        action = 'picked up'
      else
        action = 'dropped off'
      end
      time = self.request_time
      person = 'Admin'
      # should be user or staff who is using the system
      sentence = "[#{type}] Package #{barcode} (in Box #{box}) was set to be #{action} by #{person}."
      return sentence
    when CONSTANT['SYNTAX_BOX_FIX']
      if self.employee
        person = 'staff '+ self.employee.user_name
      else
        person = 'unknown user'
      end
      box = self.box.locker.name + '-' + self.box.name
      # should be user or staff who is using the system
      time = self.request_time
      sentence = "[Box Fixed] Box #{box} was fixed by #{person}. "
      if self.package
        barcode = self.package.barcode
        sentence = sentence + "Package #{barcode} was attached."
      end
      return sentence
    when CONSTANT['SYNTAX_PACKAGE_CREATE']
      type = self.print_package_status
      barcode = self.package.barcode
      person = 'Admin'
      # should be user or staff who is using the system
      time = self.request_time
      sentence = "[#{type}] Package #{barcode} was created by #{person}. "
      return sentence
    when CONSTANT['SYNTAX_PACKAGE_ASSIGN']
      type = self.print_package_status
      barcode = self.package.barcode
      box = self.box.locker.name + '-' + self.box.name
      person = 'Admin'
      # should be user or staff who is using the system
      time = self.request_time
      sentence = "[#{type}] Package #{barcode} was assigned into Box #{box} by #{person}. "
      return sentence
    when CONSTANT['SYNTAX_PACKAGE_ASSIGN_BACKUP']
      type = self.print_package_status
      barcode = self.package.barcode
      box = self.box.locker.name + '-' + self.box.name
      person = 'Admin'
      # should be user or staff who is using the system
      time = self.request_time
      sentence = "[#{type}] Package #{barcode} was assigned queuing for Box #{box} by #{person}. "
      return sentence
    when CONSTANT['SYNTAX_PACKAGE_DESTROYED']
      type = self.print_package_status
      barcode = self.package.barcode
      person = 'Admin'
      # should be user or staff who is using the system
      time = self.request_time
      sentence = "[#{type}] Package #{barcode} was destroyed by #{person}. "
      return sentence
    when CONSTANT['SYNTAX_PACKAGE_RESET']
      type = 'Package Reset'
      status = self.print_package_status
      barcode = self.package.barcode
      box = self.box.locker.name + '-' + self.box.name
      person = 'Admin'
      # should be user or staff who is using the system
      time = self.request_time
      sentence = "[#{type}] Package (originally assigned into Box #{box}) #{barcode} was reset to #{status} by #{person}. "
      return sentence
    when CONSTANT['SYNTAX_BOX_INTRUDED']
      type = 'Box Intruded'
      box = self.box.locker.name + '-' + self.box.name
      sentence = "[#{type}] Box #{box} was opened by unknown method."
      if self.package
        sentence += " Package #{self.package.barcode} was in the box."
      end
      return sentence
    else
      return '-'
    end
  end
end
