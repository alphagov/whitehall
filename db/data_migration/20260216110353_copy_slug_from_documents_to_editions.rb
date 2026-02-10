affected_rows = ActiveRecord::Base.connection.update("UPDATE editions e JOIN documents d ON e.document_id = d.id SET e.slug = d.slug")
puts "Updated #{affected_rows}."
