class AddPublishedAtToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :published_at, :datetime
    update %{
      UPDATE documents SET documents.published_at = documents.updated_at WHERE state = 'published'
    }
  end
end
