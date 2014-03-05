require 'digest/sha1'

class Access < ActiveRecord::Base
  belongs_to :box
  
  def generate_pin
    rand = Random.new
    pin = rand.rand(999999).to_s 
    self.barcode = nil
    logger.info pin # for debugging
    self.pin = Digest::SHA1.hexdigest pin
    self.update_request_id = self.box.locker.access_request_id + 1
    if self.save
      return pin
    end
    return nil
  end
  
  def save_barcode barcode
    self.barcode = Digest::SHA1.hexdigest barcode
    self.pin = nil
    self.update_request_id = self.box.locker.access_request_id + 1
    logger.info self.barcode 
    if self.save
      return true
    end
    return false
  end
  
  def clear
    self.barcode = nil
    self.pin = nil
    self.update_request_id = self.box.locker.access_request_id + 1
    if self.save
      return true
    end
    return false
  end
  
end
