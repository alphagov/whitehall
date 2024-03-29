When(/^I draft a new detailed guide "([^"]*)"$/) do |title|
  create(:government)
  begin_drafting_document type: "detailed_guide", title:, previously_published: false, all_nation_applicability: true
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
  click_button "Save and go to document summary"
  publish(force: true)
end
