class DropCachedCountsFromClassifications < ActiveRecord::Migration
  def up
    remove_column :classifications, :published_edition_count
    remove_column :classifications, :published_policies_count
  end
end
