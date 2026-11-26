class AddPositionToNavigationItems < ActiveRecord::Migration[8.1]
  def change
    add_column :navigation_items, :position, :integer
  end
end
