class ChangeLoggingsTypeToInteger < ActiveRecord::Migration
  def self.up
    change_column :loggings, :type, :integer
    change_column :loggings, :action_type, :integer
    rename_column :loggings, :type, :log_type
  end
  
  def self.down
    rename_column :loggings, :log_type, :type
    change_column :loggings, :action_type, :tinyint
    change_column :loggings, :type, :tinyint
  end
end
