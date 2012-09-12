class RemoveConsultationDocumentIdColumn < ActiveRecord::Migration
  def up
    remove_column :editions, :consultation_document_id
  end

  def down
    add_column :editions, :consultation_document_id, :integer
  end
end
