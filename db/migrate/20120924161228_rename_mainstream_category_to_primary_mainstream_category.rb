class RenameMainstreamCategoryToPrimaryMainstreamCategory < ActiveRecord::Migration
  def change
    rename_column :editions, :mainstream_category_id, :primary_mainstream_category_id
  end
end
