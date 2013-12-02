class AddBarcodeToPackages < ActiveRecord::Migration
  def change
    add_column :packages, :barcode, :string
  end
end
