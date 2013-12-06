class LoggingsController < ApplicationController
  layout 'console'
  
  def index
    @loggings = Logging.all
  end
end
