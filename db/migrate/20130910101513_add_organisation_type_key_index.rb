class AddOrganisationTypeKeyIndex < ActiveRecord::Migration
  def change
    add_index :organisations, :organisation_type_key
  end
end
