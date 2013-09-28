class CreatePackages < ActiveRecord::Migration
  def change
    create_table :packages do |t|
      t.integer :user_id
      t.integer :locker_id
      t.integer :size

      t.timestamps
    end
  end
end
