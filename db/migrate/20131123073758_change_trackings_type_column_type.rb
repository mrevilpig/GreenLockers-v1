class ChangeTrackingsTypeColumnType < ActiveRecord::Migration
  def self.up
   change_column :trackings, :type, :tinyint
  end

  def self.down
   change_column :trackings, :type, :blob
  end
end
