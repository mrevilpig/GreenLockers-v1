class CreateDevicelogs < ActiveRecord::Migration
  def change
    create_table :devicelogs do |t|
      t.integer :locker_id
      t.integer :type
      t.string :barcode
      t.integer :employee_id
      t.datetime :time
      t.integer :package_id
      t.integer :package_status
      t.timestamps
    end
  end
end
