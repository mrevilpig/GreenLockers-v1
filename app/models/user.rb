class User < ActiveRecord::Base
  has_many :packages
  belongs_to :branch, foreign_key :preferred_branch_id
end
