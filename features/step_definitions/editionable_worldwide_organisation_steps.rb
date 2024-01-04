Given(/^The editionable worldwide organisations feature flag is (enabled|disabled)$/) do |enabled|
  @test_strategy ||= Flipflop::FeatureSet.current.test!
  @test_strategy.switch!(:editionable_worldwide_organisations, enabled == "enabled")
end

Given(/^an editionable worldwide organisation "([^"]*)"$/) do |title|
  worldwide_organisation = create(:editionable_worldwide_organisation, title:)
  worldwide_organisation.main_office = create(:worldwide_office, worldwide_organisation: nil, edition: worldwide_organisation, title: "Main office for #{title}")
end

Given(/^an editionable worldwide organisation "([^"]*)" with offices "([^"]*)" and "([^"]*)"$/) do |title, contact_1_title, contact_2_title|
  worldwide_organisation = create(:editionable_worldwide_organisation, title:)
  worldwide_organisation.add_office_to_home_page!(create(:worldwide_office, worldwide_organisation: nil, edition: worldwide_organisation, contact: create(:contact, title: contact_1_title)))
  worldwide_organisation.add_office_to_home_page!(create(:worldwide_office, worldwide_organisation: nil, edition: worldwide_organisation, contact: create(:contact, title: contact_2_title)))
end

Given(/^An editionable worldwide organisation "([^"]*)" with home page offices "([^"]*)" and "([^"]*)"$/) do |title, office_1_title, office_2_title|
  worldwide_organisation = create(:editionable_worldwide_organisation, title:)
  worldwide_organisation.add_office_to_home_page!(create(:worldwide_office, worldwide_organisation: nil, edition: worldwide_organisation, contact: create(:contact, title: "Main office")))
  worldwide_organisation.add_office_to_home_page!(create(:worldwide_office, worldwide_organisation: nil, edition: worldwide_organisation, contact: create(:contact, title: office_1_title)))
  worldwide_organisation.add_office_to_home_page!(create(:worldwide_office, worldwide_organisation: nil, edition: worldwide_organisation, contact: create(:contact, title: office_2_title)))
end

When(/^I choose "([^"]*)" to be the main office for the editionable worldwide organisation$/) do |contact_title|
  WorldwideOffice.joins(contact: :translations).where(contact_translations: { title: contact_title }).first
  visit admin_editionable_worldwide_organisation_path(EditionableWorldwideOrganisation.last)
  click_link "Edit draft"
  click_link "Offices"

  click_link "Set main office"
  choose contact_title
  click_button "Save"
end

When(/^I visit the reorder offices page/) do
  visit admin_worldwide_organisation_worldwide_offices_path(EditionableWorldwideOrganisation.last)
  click_link "Reorder"
end

When(/^I reorder the offices/) do
  page.find(".gem-c-reorderable-list").first("li").click_button("Down")
  click_button "Save"
end

When(/^I draft a new worldwide organisation "([^"]*)" assigned to world location "([^"]*)"$/) do |title, world_location|
  begin_drafting_worldwide_organisation(title:, world_location:)
  click_button "Save and go to document summary"
end

When(/^I add an editionable worldwide organisation "([^"]*)" office for the home page with address, phone number, and some services$/) do |description|
  service1 = create(:worldwide_service, name: "Dance lessons")
  _service2 = create(:worldwide_service, name: "Courses in advanced sword fighting")
  service3 = create(:worldwide_service, name: "Beard grooming")

  visit admin_worldwide_organisation_worldwide_offices_path(EditionableWorldwideOrganisation.last)
  click_link "Create new office"
  fill_in_contact_details(title: description, feature_on_home_page: "yes")

  select WorldwideOfficeType.all.sample.name, from: "Office type"

  check service1.name
  check service3.name

  click_on "Save"
end

When(/^I delete the "([^"]*)" office for the worldwide organisation$/) do |_office|
  visit admin_editionable_worldwide_organisation_path(EditionableWorldwideOrganisation.last)
  click_link "Edit draft"
  click_link "Offices"

  click_link "Delete"
  expect(page).to have_text("Are you sure you want to delete \"Main office for Test Worldwide Organisation\"")

  click_button "Delete"
end

Then(/^I should be able to remove all services from the editionable worldwide organisation "(.*?)" office$/) do |description|
  worldwide_office = WorldwideOffice.joins(contact: :translations).where(contact_translations: { title: description }).first
  visit edit_admin_worldwide_organisation_worldwide_office_path(worldwide_organisation_id: EditionableWorldwideOrganisation.last.id, id: worldwide_office.id)
  available_services = worldwide_office.services.each { |service| uncheck "worldwide_office_service_ids_#{service.id}" }
  click_on "Save"

  visit edit_admin_worldwide_organisation_worldwide_office_path(worldwide_organisation_id: EditionableWorldwideOrganisation.last.id, id: worldwide_office.id)
  available_services.each do |service|
    expect(page).to have_field("worldwide_office_service_ids_#{service.id}", checked: false)
  end
end

Then(/^the worldwide organisation "([^"]*)" should have been created$/) do |title|
  @worldwide_organisation = EditionableWorldwideOrganisation.find_by(title:)

  expect(@worldwide_organisation).to be_present
  expect(@worldwide_organisation.logo_formatted_name).to eq("Logo\r\nformatted\r\nname\r\n")
end

And(/^I should see it has been assigned to the "([^"]*)" world location$/) do |title|
  expect(@worldwide_organisation.world_locations.first.name).to eq(title)
end

And(/^I add a Welsh translation of the worldwide organisation "([^"]*)" named "([^"]*)"$/) do |title, translated_title|
  visit_edition_admin(title)
  click_link "Add translation"
  select "Cymraeg (Welsh)", from: "Choose language"
  click_button "Next"
  fill_in "Translated title (required)", with: translated_title
  click_button "Save"
end

Then(/^I should see the Welsh translated title "([^"]*)" for the "([^"]*)" worldwide organisation$/) do |translated_title, title|
  @worldwide_organisation = EditionableWorldwideOrganisation.find_by(title:)

  I18n.with_locale(:cy) do
    expect(@worldwide_organisation.title).to eq(translated_title)
  end
end

Given(/^a role "([^"]*)" exists$/) do |name|
  create(:role, name:)
end

And(/^I edit the worldwide organisation "([^"]*)" adding the role of "([^"]*)"$/) do |title, role|
  begin_editing_document(title)
  select role, from: "Roles"
  click_button "Save and go to document summary"
end

Then(/^I should see the "([^"]*)" role has been assigned to the worldwide organisation "([^"]*)"$/) do |role, title|
  @worldwide_organisation = EditionableWorldwideOrganisation.find_by(title:)
  expect(@worldwide_organisation.roles.first.name).to eq(role)
end

Given(/^a social media service "([^"]*)" exists$/) do |name|
  create(:social_media_service, name:)
end

And(/^I edit the worldwide organisation "([^"]*)" adding the social media service of "([^"]*)" with title "([^"]*)" at URL "([^"]*)"$/) do |title, social_media_service_name, social_media_title, social_media_url|
  begin_editing_document(title)
  click_link "Social media accounts"
  click_link "Add new social media account"
  select social_media_service_name, from: "Service (required)"
  fill_in "URL (required)", with: social_media_url
  fill_in "Title", with: social_media_title
  click_button "Save"
end

And(/^I edit the worldwide organisation "([^"]*)" changing the social media account with title "([^"]*)" to "([^"]*)"$/) do |title, _old_social_media_title, new_social_media_title|
  begin_editing_document(title)
  click_link "Social media accounts"
  click_link "Edit"
  fill_in "Title", with: new_social_media_title
  click_button "Save"
end

And(/^I edit the worldwide organisation "([^"]*)" deleting the social media account with title "([^"]*)"$/) do |title, _social_media_title|
  begin_editing_document(title)
  click_link "Social media accounts"
  click_link "Delete"
  click_button "Delete"
end

Then(/^I should see the "([^"]*)" social media site has been assigned to the worldwide organisation "([^"]*)"$/) do |social_media_title, title|
  @worldwide_organisation = EditionableWorldwideOrganisation.find_by(title:)
  expect(@worldwide_organisation.social_media_accounts.first.title).to eq(social_media_title)
end

Then(/^I should see the worldwide organisation "([^"]*)" has no social media accounts$/) do |title|
  @worldwide_organisation = EditionableWorldwideOrganisation.find_by(title:)
  expect(@worldwide_organisation.social_media_accounts).to be_empty
end

Then(/^the "([^"]*)" should be marked as the main office for the editionable worldwide organisation$/) do |contact_title|
  admin_worldwide_organisation_worldwide_offices_path(EditionableWorldwideOrganisation.last)

  within ".app-vc-worldwide-offices-index-office-summary-card-component", match: :first do
    expect(page).to have_content contact_title
    assert_selector ".govuk-summary-list__row:nth-child(4) .govuk-summary-list__key", text: "Main office"
    assert_selector ".govuk-summary-list__row:nth-child(4) .govuk-summary-list__value", text: "Yes"
  end
end

Then(/^The "([^"]*)" worldwide organisation should have no offices$/) do |title|
  worldwide_organisation = EditionableWorldwideOrganisation.find_by(title:)
  expect(worldwide_organisation.offices.count).to be(0)
end

Then(/^I should see that the list of offices for the worldwide organisation is empty$/) do
  expect(page).to have_current_path(admin_worldwide_organisation_worldwide_offices_path(EditionableWorldwideOrganisation.last))
  expect(page).to have_text("No offices.")
end

Then(/^I should see that the list of offices are ordered "([^"]*)" then "([^"]*)"$/) do |first_office, second_office|
  expect(page).to have_current_path(reorder_admin_worldwide_organisation_worldwide_offices_path(EditionableWorldwideOrganisation.last))

  reorderable_list = page.find(".gem-c-reorderable-list")
  expect(reorderable_list).to have_selector("li", count: 2)

  first_item = reorderable_list.first("li")
  last_item = reorderable_list.all("li").last

  expect(first_item).to have_text(first_office)
  expect(first_item).to have_button("Down")
  expect(first_item).not_to have_button("Up")

  expect(last_item).to have_text(second_office)
  expect(last_item).to have_button("Up")
  expect(last_item).not_to have_button("Down")
end
