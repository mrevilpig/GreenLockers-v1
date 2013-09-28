class CreateBranches < ActiveRecord::Migration
  def change
    create_table :branches do |t|
      t.string :name
      t.string :st_address
      t.string :apt_address
      t.string :city
      t.integer :state_id
      t.string :zip

      t.timestamps
    end
  end
end
