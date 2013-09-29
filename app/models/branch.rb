class Branch < ActiveRecord::Base
  has_many :lockers
  has_many :trackings
  has_many :users
end
