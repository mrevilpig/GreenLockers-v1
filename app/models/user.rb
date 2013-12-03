class User < ActiveRecord::Base
  has_many :packages
  has_many :permissions
  belongs_to :preferred_branch
  
  def send_pick_up_pin pin
    
  end
  
  def send_drop_off_pin pin
    
  end
  
  def send_picked_up_notification
    
  end
  
  def send_dropped_off_notification
    
  end
  
end
