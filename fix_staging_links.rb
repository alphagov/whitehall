Document.record_timestamps = false
documents = Document.where("body like '%whitehall.staging%'")
documents.each do |document|
  fixed_body = document.body.gsub(/whitehall\.staging/, "whitehall.preview")
  document.update_attribute(:body, fixed_body)
  puts "Updated document #{document.id}"
end