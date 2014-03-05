class AddColumnRequestTimeAndPackageIdToLoggings < ActiveRecord::Migration
  def change
    add_column :loggings, :request_time, :datetime
    add_column :loggings, :package_id, :integer
    add_column :loggings, :package_status, :integer
    add_column :loggings, :syntax_type, :integer
    
    add_index :loggings, :package_id
  end
end
