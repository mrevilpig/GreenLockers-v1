class AddColumnsToLoggings < ActiveRecord::Migration
  def change
    add_column :loggings, :box_status, :integer
    add_column :loggings, :action_type, :tinyint
  end
end
