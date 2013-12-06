class Employee < ActiveRecord::Base
  has_many :packages
  has_many :loggings
end
