class RenamePublishedAtToMajorChangePublishedAt < ActiveRecord::Migration
  def change
    rename_column :editions, :published_at, :major_change_published_at
  end
end
