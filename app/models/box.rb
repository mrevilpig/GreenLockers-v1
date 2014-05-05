require 'yaml'

class Box < ActiveRecord::Base
  belongs_to :locker
  has_many :loggings
  has_many :permissions
  has_one :package
  has_one :backup_package, :foreign_key => 'backup_box_id', :class_name => 'Package'
  has_one :access
  delegate :branch, :to => :locker
  CONSTANT = YAML.load_file("config/constant.yml")
  
  # assign a box for package delivery
  def deliver_package package_id
    # remove the item in previous box if any
    current = self.package
    if current and self.status == CONSTANT['BOX_DELIVERING']
      current.status = CONSTANT['PACKAGE_WAITING_FOR_DELIVERY']
      self.status = CONSTANT['BOX_IDLE']
      self.package = nil
      self.access.clear
      self.save!
      current.save!
      Logging.log_manual_action self, current
    elsif current
      return false
    end
    return true if package_id.nil?
    
    if self.status == CONSTANT['BOX_IDLE']
      package = Package.find package_id
      return false if package.nil?
      # find previous box if any
      prev_box = package.box
      prev_backup_box = package.backup_box
      if prev_box or prev_backup_box
        package.status = CONSTANT['PACKAGE_WAITING_FOR_DELIVERY']
        package.save!
        if prev_box and ( prev_box.status == CONSTANT['BOX_DELIVERING'] or prev_box.status == CONSTANT['BOX_RETURNING'] )
          Logging.log_manual_action prev_box, package
          prev_box.status = CONSTANT['BOX_IDLE']
          prev_box.package = nil
        else
          Logging.log_manual_action prev_backup_box, package
          prev_backup_box.backup_package = nil
        end
        # save it later if the new assignment is successful
      end
      return false if package.status != CONSTANT['PACKAGE_WAITING_FOR_DELIVERY'].to_i
      # assign to new box
      package.box_id = self.id
      package.status = CONSTANT['PACKAGE_ENROUTE_DELIVERY']
      if package.save
        self.status = CONSTANT['BOX_DELIVERING']
        self.access.save_barcode package.barcode
        if self.save
          Logging.log_manual_action self, package
          if prev_box and prev_box.status == CONSTANT['BOX_IDLE']
            prev_box.access.clear
            prev_box.save!
          elsif prev_backup_box
            prev_backup_box.save!
          end
          return true
        end
      end
    end
    return false
  end
  
  # package delivered by deliverman
  def package_delivered
    self.status = CONSTANT['BOX_DELIVERED']
    self.package.status = CONSTANT['PACKAGE_DELIVERED_DELIVERY']
    if self.package.save
      if self.save
        pin = self.access.generate_pin
        if pin
          self.package.user.send_pick_up_pin pin  #TODO
          return true
        end
      end
    end
    return false
  end
  
  # package picked up by user
  def package_picked_up
    self.status = CONSTANT['BOX_IDLE']
    package = self.package
    package.user.send_picked_up_notification   #TODO
    package.status = CONSTANT['PACKAGE_DONE_DELIVERY']
    if package.save
      self.package = nil
      if self.save
        if self.access.clear
          return true
        end
      end
    end
    return false
  end
  
  # assign box for drop off
  def drop_off_package package_id
    return false if package_id.nil?
    current = self.package
    if current and self.status == CONSTANT['BOX_DELIVERING']
      current.status = CONSTANT['PACKAGE_WAITING_FOR_DELIVERY']
      self.status = CONSTANT['BOX_IDLE']
      self.package = nil
      self.access.clear
      self.save!
      current.save!
      Logging.log_manual_action self, current
    elsif current
      return false
    end
    if self.status == CONSTANT['BOX_IDLE']
      package = Package.find package_id
      return false if package.nil?
      prev_box = package.box
      if prev_box
        package.status = CONSTANT['PACKAGE_WAITING_FOR_DROP_OFF']
        package.save!
        Logging.log_manual_action prev_box, package
        prev_box.status = CONSTANT['BOX_IDLE']
        prev_box.package = nil
        # save it later if the new assignment is successful
      end
      return false if package.status != CONSTANT['PACKAGE_WAITING_FOR_DROP_OFF'].to_i
      package.box_id = self.id
      package.status = CONSTANT['PACKAGE_ENROUTE_DROP_OFF']
      if package.save
        self.status = CONSTANT['BOX_RETURNING']
        if self.save
          pin = self.access.generate_pin
          if pin
            package.user.send_drop_off_pin pin
            Logging.log_manual_action self, package
            if prev_box
              prev_box.access.clear
              prev_box.save!
            end
            return true
          end
        end
      end
    end
    return false
  end
  
  
  # package dropped off by user
  def package_dropped_off
    self.status = CONSTANT['BOX_RETURNED']
    self.package.user.send_dropped_off_notification
    self.package.status = CONSTANT['PACKAGE_DROPPED_OFF_DROP_OFF']
    if self.package.save
      if self.save
        if self.access.save_barcode self.package.barcode
          #enable backup capacity
          #assign_employee to pick up
          return true
        end
      end
    end
    return false
  end
  
  # package received by deliverman
  def drop_off_package_received
    self.status = CONSTANT['BOX_IDLE']
    package = self.package
    package.status = CONSTANT['PACKAGE_DONE_DROP_OFF']
    if package.save
      self.package = nil
      if self.save
        if self.access.clear
          backup_package = self.backup_package
          if backup_package
            backup_package.status = CONSTANT['PACKAGE_WAITING_FOR_DELIVERY']
            self.backup_package = nil
            self.save!
            backup_package.save!
            deliver_package backup_package.id
          end
          return true
        end
      end
    end
    return false
  end
  
  # assign backup package for delivery right after dropoff is picked up
  def assign_backup_package package_id
    return false if self.status != CONSTANT['BOX_RETURNED']
    #package.backup_box_id = self.id
    current = self.backup_package
    if current
      current.status = CONSTANT['PACKAGE_WAITING_FOR_DELIVERY']
      self.backup_package = nil
      self.save!
      current.save!
      Logging.log_manual_action self, current
    end 
    if package_id.nil?
      return true
    end
    package = Package.find package_id
    return false if package.nil?
    prev_box = package.box
    prev_backup_box = package.backup_box
    if prev_box or prev_backup_box
      package.status = CONSTANT['PACKAGE_WAITING_FOR_DELIVERY']
      package.save!
      if prev_box and ( prev_box.status == CONSTANT['BOX_DELIVERING'] or prev_box.status == CONSTANT['BOX_RETURNING'] )
        Logging.log_manual_action prev_box, package
        prev_box.status = CONSTANT['BOX_IDLE']
        prev_box.package = nil
      else
        Logging.log_manual_action prev_backup_box, package
        prev_backup_box.backup_package = nil
      end
      # save it later if the new assignment is successful
    end
    return false if package.status != CONSTANT['PACKAGE_WAITING_FOR_DELIVERY'].to_i
    self.backup_package = package
    package.status = CONSTANT['PACKAGE_QUEUING_DELIVERY']
    if package.save and self.save
      Logging.log_manual_action self, package
      if prev_box  and prev_box.status == CONSTANT['BOX_IDLE']
        prev_box.access.clear
        prev_box.save!
      elsif prev_backup_box
        prev_backup_box.save!
      end
      return true
    end
    return false
  end
  
  def remote_open
    uri = URI.parse("http://echo.jsontest.com/status/true")

    http = Net::HTTP.new(uri.host, uri.port)
    #request = Net::HTTP::Get.new(uri.request_uri)
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data({"device_id" => self.locker.name.to_s, "box_id" => self.name.to_s})
    #request.basic_auth("username", "password")
    response = http.request(request)
    if response.body
      body = JSON.parse response.body
      if body["status"] == 'true'
        return true
      end
    end
    return false
  end
  
  def init_box
    access_params = {}
    access_params[:box_id] = self.id
    a = Access.new(access_params)
    if a.save
      return true
    end
    return false
  end

  def print_size
    case self.size
    when 1
      return "Small" 
    when 2
      return "Medium"
    when 3
      return "Large"
    else
      return "Unknown"
    end
  end
  
  def print_status
    constant = YAML.load_file("config/constant.yml")
    case self.status
    when constant['BOX_IDLE']
      return "Idle" 
    when constant['BOX_DELIVERING']
      return "Delivering"
    when constant['BOX_DELIVERED']
      return "Delivered"
    when constant['BOX_RETURNING']
      return "Returning"
    when constant['BOX_RETURNED']
      return "Returned"
    when constant['BOX_ERROR']
      return "Error"
    else
      return "Unknown"
    end
  end

end
