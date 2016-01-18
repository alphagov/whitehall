class AddContentIdToTakePartPages < ActiveRecord::Migration
  def change
    add_column :take_part_pages, :content_id, :string
  end
end
