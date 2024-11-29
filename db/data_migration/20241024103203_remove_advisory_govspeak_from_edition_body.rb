published_content_containing_advisory_govspeak = []

regex = Regexp.new(/(^@)([\s\S]*?)(@?)(?=(?:^\$CTA|\r?\n\r?\n|^@|$))/m).to_s

Edition
.where(state: "published")
.joins("RIGHT JOIN edition_translations ON edition_translations.edition_id = editions.id")
.where("body REGEXP ?", regex)
.find_each do |object|
  published_content_containing_advisory_govspeak << object.content_id
end

HtmlAttachment
.joins(:govspeak_content)
.where(deleted: false)
.where.not(attachable: nil)
.where("govspeak_contents.body REGEXP ?", regex)
.find_each do |object|
  next unless object.attachable.state == "published"

  published_content_containing_advisory_govspeak << object.content_id
end

puts published_content_containing_advisory_govspeak.count
unfound_docs = []

published_content_containing_advisory_govspeak.each do |content_id|
  record = Document.find_by(content_id:) || Attachment.find_by(content_id:)

  unless record
    puts "No document or attachment found for content_id: #{content_id}"
    unfound_docs << content_id
    next
  end

  slug = record.slug
  body = record.body

  puts "Processing #{slug}"

  # Probably explain this
  matches = body.scan(/(^@)([\s\S]*?)(@?)(?=(?:^\$CTA|\r?\n\r?\n|^@|$))/m)

  next unless matches.any?

  puts "Matches found: #{matches.size}"

  new_body = body.gsub(/(^@)([\s\S]*?)(@?)(?=(?:^\$CTA|\r?\n\r?\n|^@|$))/m) do
    content = Regexp.last_match(1)
    "^#{content}^"
  end

  if new_body != body
    record.update!(body: new_body)
    puts "Modified body for #{slug}"
  end
end

puts unfound_docs

# Republish if state: published.
PublishingApiDocumentRepublishingWorker.new.perform(edition.document.id)
Whitehall::PublishingApi.republish_document_async(edition.document, bulk: true)

# One page missing
# What to do about consultations? govspeak can be in body or in the outcome details https://www.gov.uk/government/consultations/online-harms-white-paper
