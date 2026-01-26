class DropParentTypeAndParentIdFromOffsiteLinks < ActiveRecord::Migration[8.0]
  def up
    safety_assured do
      remove_column :offsite_links, :parent_id
      remove_column :offsite_links, :parent_type
    end
  end
end
