class ChangeColumnNameInPackages < ActiveRecord::Migration
  def change
    rename_column :packages, :locker_id, :box_id
  end
end
