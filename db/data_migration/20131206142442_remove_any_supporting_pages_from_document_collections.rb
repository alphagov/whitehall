ActiveRecord::Base.connection.execute %{
  DELETE document_collection_group_memberships
  FROM document_collection_group_memberships INNER JOIN documents
  ON document_collection_group_memberships.document_id = documents.id
  WHERE documents.document_type = "SupportingPage"
}
