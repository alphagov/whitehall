class CreateAdditionalMainstreamLink < ActiveRecord::Migration
  def change
    add_column :editions, :additional_related_mainstream_content_url, :string
    add_column :editions, :additional_related_mainstream_content_title, :string
  end
end