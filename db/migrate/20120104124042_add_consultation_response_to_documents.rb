class AddConsultationResponseToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :consultation_document_identity_id, :integer
  end
end
