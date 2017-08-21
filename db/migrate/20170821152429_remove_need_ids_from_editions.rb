class RemoveNeedIdsFromEditions < ActiveRecord::Migration
  def change
    remove_column :editions, :need_ids, :string
  end
end
