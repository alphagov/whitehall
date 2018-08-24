class AddNewsPageContentIdToWorldLocation < ActiveRecord::Migration[5.1]
  def change
    add_column :world_locations, :news_page_content_id, :string
  end
end
