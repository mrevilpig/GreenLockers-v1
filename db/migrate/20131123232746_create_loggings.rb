class CreateLoggings < ActiveRecord::Migration
  def change
    create_table :loggings do |t|
      t.datetime :open_time
      t.datetime :close_time
      t.integer :occupied_when_open   ,limit: 1
      t.integer :occupied_when_close  ,limit: 1
      t.integer :type                 ,limit: 1
      t.integer :box_id
      t.integer :employee_id
    end
    
    add_index :loggings, :employee_id
    add_index :loggings, :box_id
  end
end
