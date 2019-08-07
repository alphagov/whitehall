class ReferenceDocumentCollectionNonWhitehallLinks < ActiveRecord::Migration[5.1]
  def change
    add_reference :document_collection_group_memberships,
                  :non_whitehall_link,
                  index: { name: "index_document_collection_non_whitehall_link" }
  end
end
