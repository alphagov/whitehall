class AddNeedIdsColumnToEditions < ActiveRecord::Migration
  def change
    add_column :editions, :need_ids, :string
  end
end
