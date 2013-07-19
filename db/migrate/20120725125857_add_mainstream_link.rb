class AddMainstreamLink < ActiveRecord::Migration
  def change
    add_column :editions, :related_mainstream_content_url, :string
    add_column :editions, :related_mainstream_content_title, :string
  end
end
