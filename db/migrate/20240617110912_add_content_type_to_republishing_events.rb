class AddContentTypeToRepublishingEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :republishing_events, :content_type, :string
  end
end
