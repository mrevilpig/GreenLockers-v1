class Package < ActiveRecord::Base
  belongs_to :user
  belongs_to :box
  belongs_to :backup_box, :class_name => 'Box'
  belongs_to :preferred_branch, :class_name => 'Branch'
  has_many :loggings
  
  def generate_barcode
    barcode = 1000000000 + self.id
    self.barcode = barcode.to_s
    self.save!
    return barcode
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
    case self.status.to_i
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
      return "Package Destroyed"
    else
      return "Unknown"
    end
  end
end
