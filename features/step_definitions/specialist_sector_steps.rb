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
