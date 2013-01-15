class RenameTimestampForSortingToPublicTimestamp < ActiveRecord::Migration
  def up
    remove_index :editions, :timestamp_for_sorting

    rename_column :editions, :timestamp_for_sorting, :public_timestamp

    add_index :editions, :public_timestamp
  end

  def down
    remove_index :editions, :public_timestamp

    rename_column :editions, :public_timestamp, :timestamp_for_sorting

    add_index :editions, :timestamp_for_sorting
  end
end
