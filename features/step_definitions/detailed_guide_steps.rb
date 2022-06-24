Given(/^a published detailed guide "([^"]*)" for the organisation "([^"]*)"$/) do |title, organisation|
  create(:government)
  organisation = create(:organisation, name: organisation)
  create(:published_detailed_guide, title: title, organisations: [organisation])
end

When(/^I draft a new detailed guide "([^"]*)"$/) do |title|
  create(:government)
  begin_drafting_document type: "detailed_guide", title: title, previously_published: false, all_nation_applicability: true
  click_button "Save"
end

Given(/^I start drafting a new detailed guide$/) do
  begin_drafting_document type: "detailed_guide", title: "Detailed Guide", previously_published: false, all_nation_applicability: true
end

Then(/^I should be able to select another image for the detailed guide$/) do
  expect(2).to eq(all(".images input[type=file]").length)
end

When(/^I publish a new edition of the detailed guide "([^"]*)" with a change note "([^"]*)"$/) do |guide_title, change_note|
  guide = DetailedGuide.latest_edition.find_by!(title: guide_title)
  stub_publishing_api_links_with_taxons(guide.content_id, %w[a-taxon-content-id])
  visit admin_edition_path(guide)
  click_button "Create new edition"
  fill_in "edition_change_note", with: change_note
  apply_to_all_nations_if_required
  click_button "Save and continue"
  click_button "Save tagging changes"
  publish(force: true)
end

Then(/^the change notes should appear in the history for the detailed guide "([^"]*)" in reverse chronological order$/) do |title|
  detailed_guide = DetailedGuide.find_by!(title: title)
  visit detailed_guide_path(detailed_guide.document)
  document_history = detailed_guide.change_history
  change_notes = find(".change-notes").all(".note")
  expect(document_history.length).to eq(change_notes.length)
  document_history.zip(change_notes).each do |history, note|
    expect(history.note).to eq(note.text.strip)
  end
end

When(/^I start drafting a new edition for the detailed guide "([^"]*)"$/) do |guide_title|
  guide = DetailedGuide.latest_edition.find_by!(title: guide_title)
  visit admin_edition_path(guide)
  click_button "Create new edition"
  fill_in "edition_change_note", with: "Example change note"
end

Then(/^there should be (\d+) detailed guide editions?$/) do |guide_count|
  expect(guide_count.to_i).to eq(DetailedGuide.count)
end
