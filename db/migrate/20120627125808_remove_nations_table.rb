class RemoveNationsTable < ActiveRecord::Migration
  def change
    drop_table :nations
  end
end
