class RemoveConsultationResponsesFromTheDatabase < ActiveRecord::Migration
  def up
    delete "DELETE edition_attachments
            FROM edition_attachments 
            INNER JOIN editions 
            ON edition_attachments.edition_id = editions.id 
            WHERE editions.type = 'ConsultationResponse'"
    delete "DELETE documents
            FROM documents
            INNER JOIN editions
            ON documents.id = editions.document_id
            WHERE editions.type = 'ConsultationResponse'"
    delete "DELETE FROM editions
            WHERE type = 'ConsultationResponse'"
  end

  def down
    # Intentionally blank.  I don't think it's worth the effort of recreating Consultation Responses from the Responses
  end
end
