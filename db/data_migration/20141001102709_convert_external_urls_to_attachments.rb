Publication.where(external: true).find_each do |edition|
  existing_ids = edition.attachment_ids
  external = ExternalAttachment.create!(title: edition.title, external_url: edition.external_url, attachable: edition)
  if existing_ids.present?
    puts "Reordering attachments for #{edition.slug}"
    existing_ids.insert(0, external.id)
    edition.reorder_attachments(existing_ids)
  end
end
