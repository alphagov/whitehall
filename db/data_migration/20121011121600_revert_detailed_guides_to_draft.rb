require 'csv'

data = CSV.read(
  File.dirname(__FILE__) + '/20121011121600_revert_detailed_guides_to_draft.csv',
  headers: false)

user = User.find_by_name("Automatic Data Importer") || return
PaperTrail.enabled = false
data.each do |row|
  guide = Document.at_slug(DetailedGuide, row[0])

  next unless guide

  latest_edition = guide.latest_edition

  next unless latest_edition

  all_editions_including_deleted = Edition.unscoped.where(document_id: guide)

  other_editions = all_editions_including_deleted - [latest_edition]

  other_editions.each do |old_edition|
    EditionAuthor.where(edition_id: old_edition).update_all(edition_id: latest_edition)
    old_edition.destroy
  end

  FactCheckRequest.where(edition_id: other_editions).update_all(edition_id: latest_edition)
  Version.where(item_id: other_editions).update_all(item_id: latest_edition)

  latest_edition.editorial_remarks.create!(author: user, body: "Reset to draft")
  latest_edition.update_attributes(state: "draft")

  latest_edition.remove_from_search_index

  puts "#{latest_edition.title} reset to draft"
end

Rummageable.commit(Whitehall.detailed_guidance_search_index_path)
