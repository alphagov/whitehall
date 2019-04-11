html_attachments_content_ids = [
  "eaa06f35-4f59-45b1-9b17-2c77b0014466",
  "2fbeedc0-4f94-4e13-b1b4-3a11b4413d12",
  "726abfa4-b464-4a6c-b334-150ae449a655",
  "64201df0-6de9-4d88-8264-26a1c009a848",
  "5c845f89-bb71-4a82-a29a-70bc4fe61c34",
  "7e567ce8-1386-4270-b940-223ac217b4dc",
  "736c0b0d-f65e-4f93-923d-4f00924a4af0",
  "0ef6da63-c152-46a8-a18e-b213ebba3c1c",
]

destination = "/government/publications/why-overseas-companies-should-set-up-in-the-uk"

html_attachments_content_ids.each do |id|
  # Only one attachment needs to be returned per content_id
  attachment = HtmlAttachment.find_by(content_id: id)

  PublishingApiRedirectWorker.new.perform(
    attachment.content_id,
    destination,
    attachment.locale || I18n.default_locale.to_s,
  )

  puts "Redirected: #{attachment.content_id}\nto #{destination}"
end
