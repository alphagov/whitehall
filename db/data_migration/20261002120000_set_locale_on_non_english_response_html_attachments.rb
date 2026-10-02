# HTML attachments on consultation outcomes, consultation public feedback and
# call for evidence outcomes were saved without a locale (so were sent to
# Publishing API as "en"), even when the parent edition's primary locale was
# something else, e.g. Welsh. Publishing API then couldn't expand their
# `parent` link to the non-English parent, so they rendered without breadcrumbs
# or the correct document type.
#
# Set each such attachment's locale to its parent edition's primary locale,
# then republish the parent documents so the attachments are re-sent with the
# correct locale. Publishing API substitutes the old "en" draft/live editions
# of the attachments when the new locale is pushed.

response_tables = {
  "ConsultationResponse" => "consultation_responses",
  "CallForEvidenceResponse" => "call_for_evidence_responses",
}

affected_document_ids = Set.new

response_tables.each do |attachable_type, table|
  attachments = HtmlAttachment
    .where(attachable_type:, locale: nil, deleted: false)
    .joins("INNER JOIN #{table} ON #{table}.id = attachments.attachable_id")
    .joins("INNER JOIN editions ON editions.id = #{table}.edition_id")
    .where.not(editions: { primary_locale: "en" })
    .select("attachments.*, editions.primary_locale AS edition_primary_locale, editions.document_id AS edition_document_id")

  attachments.each do |attachment|
    puts "Setting locale of HtmlAttachment #{attachment.id} (#{attachment.content_id}) to #{attachment.edition_primary_locale}"
    attachment.update_columns(locale: attachment.edition_primary_locale)
    affected_document_ids << attachment.edition_document_id
  end
end

puts "Republishing #{affected_document_ids.size} documents"

Document.where(id: affected_document_ids.to_a).find_each do |document|
  Whitehall::PublishingApi.republish_document_async(document, bulk: true)
end
