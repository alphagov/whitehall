slug = "govuk-pay"
redirect_path = "https://www.payments.service.gov.uk"

document = Document.find_by(slug: slug)
exit unless document

attachment_content_ids = document.editions.flat_map do |edition|
  edition.attachments.map(&:content_id)
end.uniq

content_ids = [document.content_id] + attachment_content_ids

document.delete

puts "#{slug} -> #{redirect_path}"

content_ids.each do |content_id|
  puts "- #{content_id}"
  PublishingApiRedirectWorker.new.perform(content_id, redirect_path, "en")
end
