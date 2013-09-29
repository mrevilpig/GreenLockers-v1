class Employee < ActiveRecord::Base
  has_many :packages
end
