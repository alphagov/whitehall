class LimitNationApplicabilitiesToPolicies < ActiveRecord::Migration
  def change
    rename_column :nation_applicabilities, :document_id, :policy_id
  end
end