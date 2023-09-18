class AddIndexForDocumentContentIds < ActiveRecord::Migration[7.0]
  def change
    add_index(:documents, :content_id)
    add_index(:attachments, :content_id)
  end
end
