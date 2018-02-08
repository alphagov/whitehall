begin
  base_path = "/government/publications/sen-and-disability-reform-s31-grant-determinations/send-preparation-for-employment-grant-2018"
  destination = "/government/publications/send-reform-funding-for-local-authorities/send-preparation-for-employment-grant-allocation-2018-to-2019"
  redirects = [
    { path: base_path, type: "exact", destination: destination }
  ]
  redirect = Whitehall::PublishingApi::Redirect.new(base_path, redirects)
  content_id = SecureRandom.uuid
  
  puts "Redirecting: #{base_path} to #{destination} with a randomly generated content_id: #{content_id}"
  
  Services.publishing_api.put_content(content_id, redirect.as_json)
  
  puts "Publishing content_id: #{content_id} with redirect #{redirect.as_json}"
  Services.publishing_api.publish(content_id, nil, locale: "en")
  
  # Remove editorial remark
  edition = Edition.find(805386)
  remarks = edition.editorial_remarks
  remarks.each{|r| r.destroy if r.body == "HTML attachment published here in error. Removed and added back here https://whitehall-admin.publishing.service.gov.uk/government/admin/publications/805384"}
rescue StandardError => e
  puts "Migration has failed with the following error: #{e.message}"
end
