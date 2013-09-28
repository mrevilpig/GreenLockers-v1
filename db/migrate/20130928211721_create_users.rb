class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :middle_name
      t.string :home_phone
      t.string :mobile_phone
      t.string :email
      t.string :st_address
      t.string :apt_address
      t.string :city
      t.integer :state_id
      t.string :zip
      t.integer :preferred_branch_id
      t.string :user_name

      t.timestamps
    end
  end
end
