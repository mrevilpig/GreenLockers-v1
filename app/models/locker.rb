class Locker < ActiveRecord::Base
  belongs_to :branch
  has_many :boxes
  has_many :packages, :through => :boxes
end
