class AddForcePublishedToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :force_published, :boolean
  end
end
