class AddContentIdToWorkingGroups < ActiveRecord::Migration
  def up
    add_column :policy_groups, :content_id, :string, null: false

    PolicyGroup.all.each do |group|
      group.update_column(:content_id, SecureRandom.uuid)
    end
  end

  def down
    remove_column :policy_groups, :content_id
  end
end
