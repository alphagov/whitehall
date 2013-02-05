class CleanupContactOrganisationAssociationAfterMakingPolymorphic < ActiveRecord::Migration
  def change
    remove_column :contacts, :organisation_id
  end
end
