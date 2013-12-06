class Logging < ActiveRecord::Base
  belongs_to :box
  belongs_to :employee
  
  def self.log_action params, box, action_type
    owo = params[:occupied_when_open] ? 1:0
    owc = params[:occupied_when_close] ? 1:0
    p = {
            open_time: Time.parse(params[:timestamp_open]), close_time: Time.parse(params[:timestamp_close]), 
                employee_id: params[:staff_id].to_i, log_type: params[:type], box_id: box.id, box_status: box.status,
                occupied_when_open: owo, occupied_when_close: owc, action_type: action_type
    }
    logger.info p
    @logging = Logging.new(p)
    @logging.save!
  end
  
  def show_open_method
    case self.log_type
    when 0
      return "Pin" 
    when 1
      return "Barcode"
    when 2
      return "Permission"
    else
      return "Unknown"
    end
  end
  
  def show_action_type
    case self.action_type
    when 0
      return "Normal" 
    when 1
      return "Weird"
    when 2
      return "Error"
    when 3
      return "Fix"
    else
      return "Unknown"
    end
  end
end
