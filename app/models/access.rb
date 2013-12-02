require 'digest/sha1'

class Access < ActiveRecord::Base
  belongs_to :box
  
  def generate_pin
    rand = Random.new
    pin = rand.rand(999999).to_s 
    self.barcode = nil
    self.pin = Digest::SHA1.hexdigest pin
    if self.save
      return pin
    end
    return nil
  end
  
  def save_barcode barcode
    self.barcode = Digest::SHA1.hexdigest barcode
    self.pin = nil
    if self.save
      return true
    end
    return false
  end
  
  def clear
    self.barcode = nil
    self.pin = nil
    if self.save
      return true
    end
    return false
  end
  
end
