class AddOrganisationIdToImport < ActiveRecord::Migration
  def change
    add_column :imports, :organisation_id, :integer
  end
end
