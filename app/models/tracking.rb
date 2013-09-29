class Tracking < ActiveRecord::Base
  belongs_to :package
  belongs_to :employee
  belongs_to :branch
end
