class Locker < ActiveRecord::Base
  belongs_to :branch
  has_one :package
end
