class AddStatusToRoles < ActiveRecord::Migration
  def up
    add_column :roles, :status, :string
    add_column :roles, :reason_for_inactivity, :string
    add_column :roles, :date_of_inactivity, :datetime

    create_table :role_supersessions do |t|
      t.integer "superseded_role_id"
      t.integer "superseding_role_id"
    end
    add_index "role_supersessions", ["superseded_role_id"], name: "index_role_supersessions_on_superseded_role_id"
    add_index "role_supersessions", ["superseding_role_id"], name: "index_role_supersessions_on_superseding_role_id"
  end

  def down
    remove_column :roles, :status
    remove_column :roles, :reason_for_inactivity
    remove_column :roles, :date_of_inactivity
    drop_table :role_supersessions
  end
end
