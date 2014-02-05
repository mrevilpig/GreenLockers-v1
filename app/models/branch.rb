class Branch < ActiveRecord::Base
  has_many :boxes, :through => :lockers
  has_many :lockers
  has_many :trackings
  has_many :packages, :foreign_key => 'preferred_branch_id', :class_name => 'Package'
  has_many :users, :foreign_key => 'preferred_branch_id', :class_name => 'User'
  belongs_to :state
  
  def full_name
    return self.name + ', ' + self.city + ', ' + self.state.abbr
  end
end
