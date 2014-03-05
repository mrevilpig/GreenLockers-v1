class LoggingsController < ApplicationController
  
  def index
    @loggings = Logging.all.order('id DESC')
  end
  
  def box_logs
    respond_to do |format|
      if params[:id].nil?
        format.json{ render json: { :status => 'error', :message => 'insuffient parameters'} }
      else
        logs = Logging.where(:box_id => params[:id]).order('id DESC')
        @logs = []
        logs.each do |l|
          log = {}
          log['action_type'] = l.show_action_type
          log['access'] = l.show_access_method
          if l.package
            log['package_info'] = l.package.barcode.to_s
          else
            log['package_info'] = '-'
          end
          log['sentence'] = l.print_sentence
          log['time'] = l.request_time.to_s
          @logs.push log
        end
        format.json{ render json: { :status => 'success', :result => @logs } }
      end
    end
    return
  end
  
  def package_logs
    respond_to do |format|
      if params[:id].nil?
        format.json{ render json: { :status => 'error', :message => 'insuffient parameters'} }
      else
        logs = Logging.where(:package_id => params[:id]).order('id DESC')
        @logs = []
        logs.each do |l|
          log = {}
          log['action_type'] = l.show_action_type
          log['access'] = l.show_access_method
          if l.box
            log['box_info'] = l.box.locker.name + '-' + l.box.name 
          else
            log['box_info'] = '-'
          end
          log['sentence'] = l.print_sentence
          log['time'] = l.request_time.to_s
          @logs.push log
        end
        format.json{ render json: { :status => 'success', :result => @logs } }
      end
    end
    return
  end
end
