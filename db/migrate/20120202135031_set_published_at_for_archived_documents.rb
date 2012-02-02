class SetPublishedAtForArchivedDocuments < ActiveRecord::Migration
  def change
    update %{
      UPDATE documents SET documents.published_at = documents.updated_at
        WHERE state = 'archived' AND documents.published_at IS NULL
    }
  end
end
