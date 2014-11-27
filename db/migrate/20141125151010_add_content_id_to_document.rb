class AddContentIdToDocument < ActiveRecord::Migration
  def change
    add_column :documents, :content_id, :string
  end
end
