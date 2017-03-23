document = Document.find_by(slug: "how-to-appeal-your-rateable-value")
correct_content_id = Services.publishing_api.lookup_content_id(base_path: "/guidance/how-to-appeal-your-rateable-value")
document.content_id = correct_content_id # "e76c9e81-9fce-48e5-8ccb-100fe77ac14c"
document.save!
