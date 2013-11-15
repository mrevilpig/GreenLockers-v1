class Box < ActiveRecord::Base
  belongs_to :locker
  has_one :package
  delegate :branch, :to => :locker
end
