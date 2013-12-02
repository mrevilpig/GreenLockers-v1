class PagesController < ApplicationController
  def index
  end

  def console
    @user_count = User.all.size
    @package_count = Package.all.size
    @employee_count = Employee.all.size
    @branch_count = Branch.all.size
    @locker_count = Locker.all.size
    @box_count = Box.all.size
    @log_count = Logging.all.size
    
    render layout: 'console'
  end
end
