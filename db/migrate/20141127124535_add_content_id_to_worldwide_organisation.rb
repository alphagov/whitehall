class AddContentIdToWorldwideOrganisation < ActiveRecord::Migration
  def change
    add_column :worldwide_organisations, :content_id, :string
  end
end
