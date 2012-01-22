class RemoveDocumentsFeatured < ActiveRecord::Migration
  def change
    featured_document_ids_without_featuring.each do |id|
      featuring_id = insert(%{
        INSERT INTO featurings (created_at, updated_at) VALUES (NOW(), NOW())
      })
      update(%{
        UPDATE documents SET featuring_id = #{featuring_id} WHERE id = #{id}
      })
    end

    remove_column :documents, :featured
  end

  def featured_document_ids_without_featuring
    select_values(%{
      SELECT documents.id
        FROM documents
        WHERE documents.featured = 1
         AND documents.featuring_id IS NULL
    })
  end
end
