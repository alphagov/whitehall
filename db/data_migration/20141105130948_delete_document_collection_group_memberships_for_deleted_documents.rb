puts "Deleting all DocumentCollectionGroupMembership records that reference deleted documents"
count = DocumentCollectionGroupMembership.where("document_id NOT IN (?)", Document.pluck(:id)).delete_all
puts "Deleted #{count} DocumentCollectionGroupMemberships that referenced deleted documents"
