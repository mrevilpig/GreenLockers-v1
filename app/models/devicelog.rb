class Devicelog < ActiveRecord::Base
  belongs_to :locker
  belongs_to :employee
  belongs_to :package
  
end
