class CreatePolicyGroupDependencies < ActiveRecord::Migration[6.1]
  def change
    create_table :policy_group_dependencies do |t|
      t.references :policy_group
      t.references :dependable, polymorphic: true
      t.timestamps
    end

    add_index :policy_group_dependencies, %i[dependable_id dependable_type policy_group_id],
              unique: true, name: "index_policy_group_dependencies_on_dependable_and_policy_group"

    PolicyGroup.all.each do |policy_group|
      Govspeak::ContactsExtractor.new(policy_group.description).contacts.uniq.each do |contact|
        PolicyGroupDependency.create(
          policy_group_id: policy_group.id,
          dependable_type: "Contact",
          dependable_id: contact.id,
        )
      end
    end
  end
end
