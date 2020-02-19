withdrawn_brexit_cta_editions = Edition.in_default_locale
  .includes(:document)
  .where("edition_translations.body LIKE ?", "%$BrexitCTA%")
  .withdrawn

withdrawn_brexit_cta_editions.each do |edition|
  edition.update(
    minor_change: true,
    body: edition.body.gsub(/\$BrexitCTA/, ""),
  )
end
