Given /^there are some specialist sectors$/ do
  stub_specialist_sectors
end

When /^I start editing a draft document$/ do
  begin_drafting_publication(title: 'A Specialist Publication')
end

Then /^I can tag it to some specialist sectors$/ do
  select_specialist_sectors_in_form
  save_document
  assert_specialist_sectors_were_saved
end

Given(/^there is a document tagged to specialist sectors$/) do
  @document = create_document_tagged_to_a_specialist_sector
  stub_content_api_tags(@document)
end

When(/^I view the document$/) do
  visit public_document_path(@document)
end

Then(/^I should see the specialist sub\-sector and its parent sector$/) do
  check_for_primary_sector_in_heading
  check_for_primary_subsector_in_title(@document.title)
  check_for_all_sectors_in_metadata
end
