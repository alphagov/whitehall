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
  # The factory is calling `refresh_index_if_required`, but in this case
  # calling the content-api will blow up because we haven't stubbed that yet. 
  Edition.any_instance.stubs(:refresh_index_if_required)
  @document = create_document_tagged_to_a_specialist_sector
  stub_content_api_tags(@document)
end

Then(/^I should see the specialist sub\-sector and its parent sector$/) do
  check_for_primary_sector_in_heading
  check_for_sectors_and_subsectors_in_metadata
end

Then(/^I should not see draft specialist sectors$/) do
  check_for_absence_of_draft_sectors_and_subsectors_in_metadata
end
