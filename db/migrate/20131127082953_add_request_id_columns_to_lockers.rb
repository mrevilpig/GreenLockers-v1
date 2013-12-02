class AddRequestIdColumnsToLockers < ActiveRecord::Migration
  def change
    add_column :lockers, :permission_request_id, :string
    add_column :lockers, :access_request_id, :string
    
    add_index :permissions, :update_request_id
    add_index :accesses, :update_request_id
  end
end
