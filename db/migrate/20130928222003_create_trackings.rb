class CreateTrackings < ActiveRecord::Migration
  def change
    create_table :trackings do |t|
      t.integer :package_id
      t.integer :employee_id
      t.datetime :time
      t.binary :type
      t.integer :branch_id

      t.timestamps
    end
  end
end
