class RemoveDetailedGuideCategories < ActiveRecord::Migration
  def up
    drop_table :edition_mainstream_categories
    drop_table :organisation_mainstream_categories
    drop_table :mainstream_categories
    remove_column :editions, :primary_mainstream_category_id
  end
end
