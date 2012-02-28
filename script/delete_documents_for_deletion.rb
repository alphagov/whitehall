Document.unscoped.where("title like '%DELETE%'").each do |document|
  latest_edition = document.document_identity.latest_edition
  if latest_edition == document
    p "deleting document_id: #{document.id}, document_identity_id: #{document.document_identity.id}"
    document.document_identity.destroy
  end
end