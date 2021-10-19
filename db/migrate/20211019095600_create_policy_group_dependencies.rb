class CreatePolicyGroupDependencies < ActiveRecord::Migration[6.1]
  def change
    create_table :policy_group_dependencies do |t|
      t.references :policy_group
      t.references :dependable, polymorphic: true
      t.timestamps
    end

    add_index :policy_group_dependencies, %i[dependable_id dependable_type policy_group_id],
              unique: true, name: "index_policy_group_dependencies_on_dependable_and_policy_group"

    PolicyGroup.all.map(&:extract_dependencies)
  end
end
