# I think I'm basically ready with this. Here's a rough outline of what the script I've written will do, but I'd really like to sit with Neil/Pete and go compare the site pre- and post-run so I'm confident I haven't missed anything:

# For every document type EXCEPT specialist guides:
# > For every published document or latest draft:
# >> Get the set of other editions (including archived

include Rails.application.routes.url_helpers
include Admin::EditionRoutesHelper

importer_user = User.find_by_name("Automatic Data Importer")
PaperTrail.enabled = false

document_types = Edition.select("distinct(type)").map(&:type) - ["SpecialistGuide"]

latest_editions = Document.where(document_type: document_types).map(&:latest_edition).compact
latest_editions.each.with_index do |latest_edition, i|

  all_editions_including_deleted = Edition.unscoped.where(document_id: latest_edition.document)
  other_editions = all_editions_including_deleted - [latest_edition]

  latest_edition_path = admin_edition_path(latest_edition) + " "

  counter = "#{(i + 1).to_s.rjust(latest_editions.length.to_s.length, " ")}/#{latest_editions.length}"
  print "(#{counter}) [#{latest_edition.type}] #{latest_edition.title}, #{latest_edition_path.strip}, #{other_editions.count} other editions:"

  other_editions.each do |other_edition|
    # include a space to match markdown formatting with title and
    # ensure we don't match /a/b/123 with /a/b/1234
    other_edition_path = admin_edition_path(other_edition) + " "

    linked_editions = Edition.published.where("body like '%#{other_edition_path}%'")
    linked_editions.each do |linked_edition|
      new_body = linked_edition.body.gsub(other_edition_path, latest_edition_path)
      linked_edition.update_attribute(:body, new_body)
      print " updated links in #{admin_edition_path(linked_edition)};"
    end

    EditionAuthor.where(edition_id: other_edition).update_all(edition_id: latest_edition)

    other_edition.destroy

    print " destroyed #{other_edition_path.strip};"
  end

  FactCheckRequest.where(edition_id: other_editions).update_all(edition_id: latest_edition)
  Version.where(item_id: other_editions).update_all(item_id: latest_edition)

  latest_edition.editorial_remarks.create!(author: importer_user, body: "Reset to draft")
  puts " reset to draft."
end

Edition.where(type: document_types).update_all(state: "draft", first_published_at: nil, published_at: nil)
Topic.update_all(published_edition_count: 0)

puts "Finished; now #{Edition.published.where(type: document_types).count} published editions"
