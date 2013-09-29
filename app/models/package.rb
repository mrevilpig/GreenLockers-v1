class Package < ActiveRecord::Base
  belongs_to :user
  belongs_to :locker
end
