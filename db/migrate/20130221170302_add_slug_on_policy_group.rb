class AddSlugOnPolicyGroup < ActiveRecord::Migration
  PolicyGroup.class_eval do
    # temporarily generate slugs for existing objects
    def should_generate_new_friendly_id?
      true
    end
  end
  def change
    add_column :policy_groups, :slug, :string
    add_index :policy_groups, :slug

    PolicyGroup.reset_column_information

    PolicyGroup.record_timestamps = false
    PolicyGroup.find_each(&:save)
    PolicyGroup.record_timestamps = true
  end
end
