brexit_cta_editions_drafts = Edition.in_default_locale
  .includes(:document)
  .where("edition_translations.body LIKE ?", "%$BrexitCTA%")
  .draft

brexit_cta_editions_drafts.each do |draft|
  draft.update(
    minor_change: true,
    body: draft.body.gsub(/\$BrexitCTA/, ""),
  )
end
