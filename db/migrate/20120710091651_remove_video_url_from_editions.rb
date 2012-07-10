class RemoveVideoUrlFromEditions < ActiveRecord::Migration
  def change
    remove_column :editions, :video_url
  end
end
