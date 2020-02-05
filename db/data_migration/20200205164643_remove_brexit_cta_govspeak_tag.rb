gds_user = User.find_by!(name: "GDS Inside Government Team")

brexit_cta_editions = Edition.in_default_locale
  .includes(:document)
  .where("edition_translations.body LIKE ?", "%$BrexitCTA%")
  .uniq

brexit_cta_editions.each do |edition|
  draft = edition.create_draft(gds_user)

  draft.update(
    minor_change: true,
    body: draft.body.gsub(/\$BrexitCTA/, ""),
  )

  PublishingApiDocumentRepublishingWorker.perform_async_in_queue(
    "bulk_republishing",
    edition.document_id,
  )
end
