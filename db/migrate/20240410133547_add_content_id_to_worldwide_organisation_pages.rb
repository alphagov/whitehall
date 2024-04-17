class AddContentIdToWorldwideOrganisationPages < ActiveRecord::Migration[7.1]
  def change
    add_column :worldwide_organisation_pages, :content_id, :string
  end
end
