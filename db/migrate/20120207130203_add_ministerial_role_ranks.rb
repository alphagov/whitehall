class AddMinisterialRoleRanks < ActiveRecord::Migration
  def change
    create_table :ranks, force: true do |t|
      t.string  :name
      t.integer :position
      t.timestamps
    end

    add_column :roles, :rank_id, :integer
  end
end