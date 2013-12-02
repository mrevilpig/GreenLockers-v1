class CreatePermissions < ActiveRecord::Migration
  def change
    create_table :permissions do |t|
      t.integer :employee_id
      t.integer :box_id
      t.integer :level            , limit: 1
      t.integer :update_request_id, limit: 8

      t.timestamps
    end
    add_index :permissions, :employee_id
    add_index :permissions, :box_id
  end
end
