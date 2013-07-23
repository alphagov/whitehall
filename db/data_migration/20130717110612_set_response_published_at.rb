responses = Response.where("published_on IS NULL AND summary <> ''").each do |response|
  response.update_column(:published_on, response.updated_at)
end
puts "#{responses.count} Responses updated with a summary and no published date"

responses = Response.joins(:attachments).where("published_on IS NULL").uniq.each do |response|
	response.update_column(:published_on, response.consultation_response_attachments.order("created_at ASC").first.created_at)
end
puts "#{responses.count} Responses updated with a attachment and no published date"
