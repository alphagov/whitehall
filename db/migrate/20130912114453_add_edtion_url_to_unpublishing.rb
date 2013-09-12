class AddEdtionUrlToUnpublishing < ActiveRecord::Migration
  def change
    add_column :unpublishings, :edition_url, :string
  end
end
