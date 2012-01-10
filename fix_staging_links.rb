Document.record_timestamps = false
documents = Document.where("body like '%whitehall.preview.alphagov.co.uk/admin%'")
documents.each do |document|
  fixed_body = document.body.gsub(/whitehall\.preview\.alphagov\.co\.uk\/admin/, "whitehall.preview.alphagov.co.uk#{Whitehall.router_prefix}/admin")
  document.update_attribute(:body, fixed_body)
  puts "Updated document #{document.id}"
end