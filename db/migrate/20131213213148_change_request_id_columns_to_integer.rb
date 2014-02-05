class ChangeRequestIdColumnsToInteger < ActiveRecord::Migration
  def self.up
    change_column :accesses, :update_request_id, :integer
    change_column :lockers, :permission_request_id, :integer
    change_column :lockers, :access_request_id, :integer
  end
  
  def self.down
    change_column :accesses, :update_request_id, :string
    change_column :lockers, :permission_request_id, :string
    change_column :lockers, :access_request_id, :string
  end
end
