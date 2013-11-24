class Logging < ActiveRecord::Base
  
  def logAction params, box, action_type
      Logging.create(:open_time => Time.parse(params[:timestamp_open]), :close_time => Time.parse(params[:timestamp_close]), 
                :employee_id => params[:staff_id], :type => params[:type], :box_id => @box.id, :box_status => @box.status,
                :occupied_when_open => occupied_when_open, :occupied_when_close => occupied_when_close, :action_type => action_type)
  end
end
