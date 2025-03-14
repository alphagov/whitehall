class RemoveRelevantToLocalGovernmentColumnFromEditions < ActiveRecord::Migration[8.0]
  def up
    remove_column :editions, :relevant_to_local_government
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
