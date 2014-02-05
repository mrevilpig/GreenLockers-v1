class Employee < ActiveRecord::Base
  has_many :packages
  has_many :loggings
  has_many :permissions
  
  def name
    if (self.first_name and self.first_name)
      return self.first_name + ' ' + self.last_name
    elsif self.first_name
      return self.first_name
    elsif self.last_name
      return self.last_name
    else
      return 'noname'
    end
  end
end
