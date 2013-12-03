require 'yaml'

class Box < ActiveRecord::Base
  belongs_to :locker
  has_many :loggings
  has_many :permissions
  has_one :package
  has_one :access
  delegate :branch, :to => :locker
  CONSTANT = YAML.load_file("config/constant.yml")
  
  # assign a box for package delivery
  def deliver_package package_id
    return false if package_id.nil?
    package = Package.find package_id
    return false if package.nil?
    if self.status == CONSTANT['BOX_IDLE']
      package.box_id = self.id
      package.status = CONSTANT['PACKAGE_ENROUTE_DELIVERY']
      if package.save
        self.status = CONSTANT['BOX_DELIVERING']
        self.access.save_barcode package.barcode
        if self.save
          return true
        end
      end
    end
    return false
  end
  
  # package delivered by deliverman
  def package_delivered
    self.status = CONSTANT['BOX_DELIVERED']
    if self.save
      pin = self.access.generate_pin
      if pin
        
        self.package.user.send_pick_up_pin pin
        return true
      end
    end
    return false
  end
  
  # package picked up by user
  def package_picked_up
    self.status = CONSTANT['BOX_IDLE']
    self.package.user.send_picked_up_notification
    self.package.status = CONSTANT['PACKAGE_DONE_DELIVERY']
    self.package.save!
    self.package = nil
    if self.save
      if self.access.clear
        return true
      end
    end
    return false
  end
  
  # assign box for drop off
  def drop_off_package package_id
    return false if package_id.nil?
    package = Package.find package_id
    return false if package.nil?
    if self.status == CONSTANT['BOX_IDLE']
      package.box_id = self.id
      package.status = CONSTANT['PACKAGE_ENROUTE_DROP_OFF']
      if package.save
        self.status = CONSTANT['BOX_RETURNING']
        if self.save
          pin = self.access.generate_pin
          if pin
            self.package.user.send_drop_off_pin pin
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
    if self.save
      if self.access.clear
        
        #assign_employee to pick up
        return true
      end
    end
    return false
  end
  
  # package received by deliverman
  def drop_off_package_received
    self.status = CONSTANT['BOX_IDLE']
    self.package.status = CONSTANT['PACKAGE_DONE_DROP_OFF']
    self.package.save!
    self.package = nil
    if self.save
      if self.access.clear
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
