class AddColumnPreferredBranchIdToPackages < ActiveRecord::Migration
  def change
    add_column :packages, :preferred_branch_id, :integer
  end
end
