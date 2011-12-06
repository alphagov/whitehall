class RenameDocumentPolicyAreas < ActiveRecord::Migration
  def change
    rename_table :document_policy_areas, :policy_area_memberships
  end
end