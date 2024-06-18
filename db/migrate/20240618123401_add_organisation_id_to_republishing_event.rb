class AddOrganisationIdToRepublishingEvent < ActiveRecord::Migration[7.1]
  def change
    add_column :republishing_events, :organisation_id, :string
  end
end
