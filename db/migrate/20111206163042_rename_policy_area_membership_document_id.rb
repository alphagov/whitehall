class RenamePolicyAreaMembershipDocumentId < ActiveRecord::Migration
  def change
    rename_column :policy_area_memberships, :document_id, :policy_id
  end
end