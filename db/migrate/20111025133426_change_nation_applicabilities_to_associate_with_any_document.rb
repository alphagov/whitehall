class ChangeNationApplicabilitiesToAssociateWithAnyDocument < ActiveRecord::Migration
  def change
    rename_column :nation_applicabilities, :policy_id, :document_id
  end
end
