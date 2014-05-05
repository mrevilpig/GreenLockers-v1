class User < ActiveRecord::Base
  has_many :packages
  belongs_to :preferred_branch, :class_name => 'Branch'
  belongs_to :state
  
  def send_pick_up_pin pin
    #TODO
  end
  
  def send_drop_off_pin pin
    #TODO
  end
  
  def send_picked_up_notification
    #TODO
  end
  
  def send_dropped_off_notification
    #TODO
  end
  
end
