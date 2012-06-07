class AddVideoUrlToEditions < ActiveRecord::Migration
  def change
    add_column :editions, :video_url, :string
  end
end