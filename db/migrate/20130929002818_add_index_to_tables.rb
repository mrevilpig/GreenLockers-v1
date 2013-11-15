class AddIndexToTables < ActiveRecord::Migration
  def change
    add_index :users, :preferred_branch_id
    add_index :boxes, :locker_id
    add_index :packages, :user_id
    add_index :packages, :locker_id
    add_index :trackings, :package_id
    add_index :trackings, :employee_id
    add_index :trackings, :branch_id
  end
end
