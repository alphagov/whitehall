Document.where(
  id: Edition.where(state: :scheduled).select(:document_id)
).all.each do |document|
  next unless document.published_edition.nil?

  puts "Saving draft for #{document.id} (content_id: #{document.content_id})"
  Whitehall::PublishingApi.save_draft(document.pre_publication_edition)
end
