require 'yaml'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_constant
  
  private 
    def set_constant
      @constant = YAML.load_file("#{Rails.root}/config/constant.yml")
    end
end
