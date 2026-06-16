When(/^I view the current edition of document "([^"]*)"$/) do |title|
  @edition = Edition.find_by(title:).document.editions.last
  visit admin_edition_path(@edition)
end

Then(/^I am told I do not have permissions to access this page/) do
  expect(page).to have_content "You do not have permission to access this page."
end

Then(/^I should not see a link to edit the access/) do
  expect(page).not_to have_link("As an administrator, you can update the access permissions of the page.", href: edit_access_limited_admin_edition_path(@edition))
end

Then(/^I should see a link to edit the access/) do
  expect(page).to have_link("As an administrator, you can update the access permissions of the page.", href: edit_access_limited_admin_edition_path(@edition))
end

When(/^I begin drafting a new document$/) do
  @org = create(:organisation, name: "Some made up org")

  visit "/government/admin/publications/new"
  select "Policy paper", from: "edition_publication_type_id"
  fill_in "edition[title]", with: "Test publication"
  fill_in "edition[summary]", with: "Test summary"
  fill_in "edition[body]", with: "Test body"
  check "Applies to all UK nations"
end

When(/^I set the Lead organisation to an org I am not in$/) do
  select @org.name, from: "edition_lead_organisation_ids_1"
end

When(/^I check the "(.+)" box$/) do |box_name|
  check box_name
end

When(/^I click "(.+)"$/) do |button_name|
  click_on button_name
end

Then(/^I should see the validation error "(.+)"$/) do |string|
  expect(page).to have_content string
end

Given(/^the access_limiting_organisations_ui feature flag is (enabled|disabled)$/) do |state|
  @test_strategy ||= Flipflop::FeatureSet.current.test!
  @test_strategy.switch!(:access_limiting_organisations_ui, state == "enabled")
end

When(/^I choose "([^"]*)"$/) do |option|
  choose option
end

When(/^I select the lead organisation as an access limiting organisation$/) do
  select @org.name, from: "edition_access_limiting_organisation_ids"
end

Given(/^I create an access limited document$/) do
  step "I begin drafting a new document"
  step "I check the \"Limit access to publishers from organisations associated with this document before you publish\" box"
  step "I click \"Save\""
end

Then(/^I should still be able to access the document$/) do
  visit current_url # refresh
  expect(page).not_to have_content "You do not have permission to access this page."
  expect(page).to have_content "Test publication"
  expect(Edition.last.organisations).to eq([@user.organisation])
end
