class CreateGroupMemberships < ActiveRecord::Migration
  def change
    create_table :group_memberships, force: true do |t|
      t.references :group
      t.references :person
      t.timestamps
    end
    add_index :group_memberships, :group_id
    add_index :group_memberships, :person_id
  end
end