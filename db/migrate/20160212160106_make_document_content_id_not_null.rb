class MakeDocumentContentIdNotNull < ActiveRecord::Migration
  def change
    Document.where(content_id: nil).find_each do |document|
      document.update_column(:content_id, SecureRandom.uuid)
    end

    change_column_null(:documents, :content_id, false)
  end
end
