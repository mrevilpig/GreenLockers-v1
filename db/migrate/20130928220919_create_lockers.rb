class CreateLockers < ActiveRecord::Migration
  def change
    create_table :lockers do |t|
      t.integer :branch_id
      t.string :name
      t.integer :size
      t.integer :status

      t.timestamps
    end
  end
end
