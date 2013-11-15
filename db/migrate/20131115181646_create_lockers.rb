class CreateLockers < ActiveRecord::Migration
  def change
    create_table :lockers do |t|
      t.integer :branch_id
      t.string :name

      t.timestamps
    end
    add_index :lockers, :branch_id
  end
end
