class CreatePrivileges < ActiveRecord::Migration
  def change
    create_table :privileges do |t|
      t.integer :employee_id
      t.integer :locker_id

      t.timestamps
    end
  end
end
