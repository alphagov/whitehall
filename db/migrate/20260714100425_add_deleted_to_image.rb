class AddDeletedToImage < ActiveRecord::Migration[8.1]
  def change
    add_column :images, :deleted, :boolean, default: false
  end
end
