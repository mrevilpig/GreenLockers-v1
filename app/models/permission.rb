class Permission < ActiveRecord::Base
  belongs_to :employee
  belongs_to :box
end
