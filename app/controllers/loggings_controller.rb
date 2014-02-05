class LoggingsController < ApplicationController
  
  def index
    @loggings = Logging.all
  end
end
