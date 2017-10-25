attachment_redirects = [
  {
    base_path: "/government/uploads/system/uploads/attachment_data/file/640413/family-spouse-04-17.pdf",
    destination: "/government/uploads/system/uploads/attachment_data/file/642757/family-spouse-04-17.pdf"
  },
  {
    base_path: "/government/uploads/system/uploads/attachment_data/file/640412/Family-privatelife-04-17.pdf",
    destination: "/government/uploads/system/uploads/attachment_data/file/642756/Family-privatelife-04-17.pdf"
  },
  {
    base_path: "/government/uploads/system/uploads/attachment_data/file/640415/EEA-permanentresidence-03-16.pdf",
    destination: "/government/uploads/system/uploads/attachment_data/file/642760/EEA-permanentresidence-03-16.pdf"
  },
]

attachment_redirects.each do |attachment_redirect|
  base_path = attachment_redirect[:base_path]
  redirects = [
    { path: base_path, type: "exact", destination: attachment_redirect[:destination] }
  ]
  redirect = Whitehall::PublishingApi::Redirect.new(base_path, redirects)
  content_id = SecureRandom.uuid
  Services.publishing_api.put_content(content_id, redirect.as_json)
  Services.publishing_api.publish(content_id, nil, locale: "en")
end
