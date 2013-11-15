class CreateBoxes < ActiveRecord::Migration
  def change
    create_table :boxes do |t|
      t.integer :locker_id
      t.string :name
      t.integer :size
      t.integer :status

      t.timestamps
    end
  end
end
