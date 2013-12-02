class AddStatusColumnToPackages < ActiveRecord::Migration
  def change
    add_column :packages, :status, :integer, limit: 2
  end
end
