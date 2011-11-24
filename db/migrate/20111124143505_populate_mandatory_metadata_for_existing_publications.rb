class PopulateMandatoryMetadataForExistingPublications < ActiveRecord::Migration
  def change
    insert %{
      INSERT INTO publication_metadata (publication_id, publication_date, created_at, updated_at)
        SELECT documents.id, CURDATE(), NOW(), NOW() FROM documents
          LEFT OUTER JOIN publication_metadata
            ON publication_metadata.publication_id = documents.id
          WHERE documents.type = 'Publication'
            AND publication_metadata.id IS NULL
    }
  end
end
