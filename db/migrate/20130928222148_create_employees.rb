class CreateEmployees < ActiveRecord::Migration
  def change
    create_table :employees do |t|
      t.string :first_name
      t.string :last_name
      t.string :middle_name
      t.string :mobile_phone
      t.string :email
      t.string :user_name
      t.integer :role
      t.string :password

      t.timestamps
    end
  end
end
