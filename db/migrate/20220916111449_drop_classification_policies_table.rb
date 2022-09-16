class DropClassificationPoliciesTable < ActiveRecord::Migration[7.0]
  def up
    drop_table :classification_policies
  end
end
