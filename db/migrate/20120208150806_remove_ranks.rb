class RemoveRanks < ActiveRecord::Migration
  def up
    drop_table :ranks
    remove_column :roles, :rank_id
  end

  def down
    create_table :ranks, force: true do |t|
      t.string  :name
      t.integer :position
      t.timestamps
    end

    add_column :roles, :rank_id, :integer
  end
end
