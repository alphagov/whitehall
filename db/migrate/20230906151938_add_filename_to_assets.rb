class AddFilenameToAssets < ActiveRecord::Migration[7.0]
  def change
    add_column :assets, :filename, :string
  end
end
