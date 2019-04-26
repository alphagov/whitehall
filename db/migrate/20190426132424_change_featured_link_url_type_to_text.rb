class ChangeFeaturedLinkUrlTypeToText < ActiveRecord::Migration[5.1]
  def change
    change_column :featured_links, :url, :text
  end
end
