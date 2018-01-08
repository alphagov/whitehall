SLUG_TO_CONTENT_ID_MAPPING = {
  "helping-government-departments-improve-their-efficiency-and-performance-to-save-the-taxpayer-money" => "5d2b59a2-7631-11e4-a3cb-005056011aef",
  "making-it-easier-to-trade" => "5c7657ab-7631-11e4-a3cb-005056011aef",
  "improving-the-uks-ability-to-absorb-respond-to-and-recover-from-emergencies" => "5c768de5-7631-11e4-a3cb-005056011aef",
}.freeze

SLUG_TO_CONTENT_ID_MAPPING.each do |slug, content_id|
  document = Document.at_slug(Policy, slug)
  other_document = Document.find_by(content_id: content_id)
  puts "\tmerging '#{document.published_edition.title}' into '#{other_document.published_edition.title}'  (setting content_id to '#{content_id}')"
  document.update_column(:content_id, content_id)
end
