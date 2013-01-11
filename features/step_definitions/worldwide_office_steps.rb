When /^I create a worldwide office "([^"]*)" with a summary and description$/ do |name|
  visit new_admin_worldwide_office_path
  fill_in "Name", with: name
  fill_in "Summary", with: "Worldwide office summary"
  fill_in "Description", with: "Worldwide **office** description"
  click_on "Save"
end

Then /^I should see the(?: updated)? worldwide office information on the public website$/ do
  office = WorldwideOffice.last
  visit worldwide_office_path(office)
  assert page.has_content?(office.name)
  assert page.has_css?("strong", text: "office")
end

Then /^the "([^"]*)" logo should show correctly with the HMG crest$/ do |name|
  office = WorldwideOffice.find_by_name(name)
  assert page.has_css?(".organisation-logo-stacked-single-identity", text: office.logo_formatted_name)
end

When /^I update the worldwide office to set the name to "([^"]*)"$/ do |new_title|
  visit edit_admin_worldwide_office_path(WorldwideOffice.last)
  fill_in "Name", with: new_title
  click_on "Save"
end

When /^I delete the worldwide office$/ do
  @office = WorldwideOffice.last
  visit edit_admin_worldwide_office_path(@office)
  click_on "delete"
end

Then /^the worldwide office should not be visible from the public website$/ do
  assert_raises(ActiveRecord::RecordNotFound) do
    visit worldwide_office_path(@office)
  end
end

Given /^a worldwide office "([^"]*)"$/ do |name|
  create(:worldwide_office, name: name)
end

When /^I add a "([^"]*)" social media link "([^"]*)"$/ do |social_service, url|
  visit edit_admin_worldwide_office_path(WorldwideOffice.last)
  select social_service, from: "Service"
  fill_in "Url", with: url
  click_on "Save"
end

Then /^the social link should be shown on the public website$/ do
  visit worldwide_office_path(WorldwideOffice.last)
  assert page.has_css?(".social-media .social-media-link")
end
