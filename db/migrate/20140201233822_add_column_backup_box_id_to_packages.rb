class AddColumnBackupBoxIdToPackages < ActiveRecord::Migration
  def change
    add_column :packages, :backup_box_id, :integer
  end
end
