class CreateAccesses < ActiveRecord::Migration
  def change
    create_table :accesses do |t|
      t.integer :box_id
      t.string :barcode
      t.string :pin
      t.string :update_request_id

      t.timestamps
    end
    add_index :accesses, :box_id
  end
end
