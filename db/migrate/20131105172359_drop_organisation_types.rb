class DropOrganisationTypes < ActiveRecord::Migration
  def change
    drop_table :organisation_types
  end
end
