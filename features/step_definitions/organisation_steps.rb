Given(/^a directory of organisations exists$/) do
  stub_organisation_homepage_in_content_store
end

Given(/^the organisation "([^"]*)" exists$/) do |name|
  create_org_and_stub_content_store(:ministerial_department, name:)
end

Given(/^two organisations "([^"]*)" and "([^"]*)" exist$/) do |first_organisation, second_organisation|
  create(:organisation, name: first_organisation)
  create(:organisation, name: second_organisation)
end

Given(/^a published publication "([^"]*)" with a PDF attachment and alternative format provider "([^"]*)"$/) do |title, organisation_name|
  organisation = Organisation.find_by!(name: organisation_name)
  publication = create(:published_publication, :with_file_attachment, title:, body: "!@1", organisations: [organisation], alternative_format_provider: organisation)
  @attachment_title = publication.attachments.first.title
  @attachment_filename = publication.attachments.first.filename
end

Given(/^I set the alternative format contact email of "([^"]*)" to "([^"]*)"$/) do |organisation_name, email|
  organisation = Organisation.find_by!(name: organisation_name)
  visit edit_admin_organisation_path(organisation)
  fill_in "organisation_alternative_format_contact_email", with: email
  click_button "Save"
end

When(/^I add a new organisation called "([^"]*)"$/) do |organisation_name|
  create(:topical_event, name: "Jazz Bizniz")

  visit new_admin_organisation_path

  fill_in "Name", with: organisation_name
  fill_in "Acronym", with: organisation_name.split(" ").collect { |word| word.chars.first }.join
  fill_in "Logo formatted name", with: organisation_name
  select "Ministerial department", from: "Organisation type"
  select "Jazz Bizniz", from: "organisation_topical_event_ids_0"
  selector = ".app-view-organisation__featured_links"
  within selector do
    expect(page).to_not have_content("English:")
    fill_in "Title", with: "Top task 1"
    fill_in "URL", with: "http://mainstream.co.uk"
  end
  click_button "Save"
end

When(/^I add a translation for an organisation called "([^"]*)"$/) do |organisation_name|
  organisation = Organisation.find_by!(name: organisation_name)
  visit admin_organisation_path(organisation)

  click_link "Translations"

  select "Cymraeg (Welsh)", from: "Locale"
  click_button "Create new translation"

  fill_in "Name", with: "Organisation Name in another language"
  fill_in "Acronym", with: "ABC"
  fill_in "Logo formatted name", with: "Organisation Name in another language"
  fill_in "Title", with: "Top task 1 in another language"
  expect(page).to have_field("organisation_featured_links[0]_title"), with: "Top task 1 in another language"
  fill_in "URL", with: "http://mainstream.wales"
  expect(page).to have_field("organisation_featured_links[0]_url"), with: "http://mainstream.co.uk"

  click_button "Save"
end

Then(/^I should be able to see "([^"]*)" in the list of organisations$/) do |organisation_name|
  within ".govuk-table" do
    expect(page).to have_content(organisation_name)
  end
end

Then(/^I should be able to see the translation for "([^"]*)" in the list of translations$/) do |organisation_name|
  organisation = Organisation.find_by!(name: organisation_name)
  visit admin_organisation_path(organisation)
  click_link "Translations"
  expect(page).to have_content("Cymraeg")
end

When(/^I add the offsite link "(.*?)" of type "(.*?)" to the organisation "(.*?)"$/) do |title, type, organisation_name|
  organisation = Organisation.find_by!(name: organisation_name)
  visit features_admin_organisation_path(organisation)

  click_link "Create new link"

  fill_in "Title (required)", with: title
  select type, from: "offsite_link_link_type"
  fill_in "Summary (required)", with: "Summary"
  fill_in "URL (required)", with: "https://www.gov.uk/jobsearch"

  click_button "Save"
end

When(/^I delete the organisation "([^"]*)"$/) do |name|
  organisation = Organisation.find_by!(name:)

  visit admin_organisations_path
  click_link "Delete #{organisation.name}", match: :first
  click_button "Delete"
end

Then(/^there should not be an organisation called "([^"]*)"$/) do |name|
  expect(Organisation.find_by(name:)).to_not be_present
end

Then(/^I should see the edit offsite link "(.*?)" on the "(.*?)" organisation page$/) do |title, _organisation_name|
  within "#non_govuk_government_links_tab" do
    expect(find("table td:first").text).to eq title
  end
end

def navigate_to_organisation(page_name)
  within("nav.sub_navigation") do
    click_link page_name
  end
end

Then(/^the alternative format contact email is "([^"]*)"$/) do |email|
  publication = Publication.last
  actual = publication.alternative_format_contact_email

  expect(email).to eq(actual)
end

Then(/^I cannot see links to Transparency data on the "([^"]*)" about page$/) do |name|
  visit_organisation_about_page name
  expect(page).to_not have_selector("a", text: "Transparency data")
end

Then(/^I can see a link to "([^"]*)" on the "([^"]*)" about page$/) do |link_text, name|
  visit_organisation_about_page name
  expect(page).to have_selector("a", text: link_text)
end

When(/^I associate a Transparency data publication to the "([^"]*)"$/) do |name|
  organisation = Organisation.find_by!(name:)
  create(:published_publication, :transparency_data, organisations: [organisation])
end

Given(/^an organisation "([^"]*)" has been assigned to handle fatalities$/) do |organisation_name|
  create(:organisation, name: organisation_name, handles_fatalities: true)
end

When(/^I visit the organisation admin page for "([^"]*)"$/) do |organisation_name|
  organisation = Organisation.find_by!(name: organisation_name)
  visit admin_organisation_path(organisation)
end

When(/^I add a new contact "([^"]*)" with address "([^"]*)"$/) do |contact_description, address|
  click_link "Contacts"
  click_link "Add"

  fill_in_contact_details(title: contact_description, street_address: address)

  click_button "Save"
end

When(/^I edit the contact to have address "([^"]*)"$/) do |address|
  click_link "Contacts"

  within ".govuk-summary-card__actions" do
    click_link "Edit"
  end

  fill_in "Street address", with: address
  click_button "Save"
end

Then(/^I should see the "([^"]*)" contact in the admin interface with address "([^"]*)"$/) do |contact_description, address|
  within ".govuk-summary-card" do
    expect(page).to have_selector("h2", text: contact_description)
    expect(page).to have_selector(".govuk-summary-list__value", text: address)
  end
end

And(/^the following roles exist within the "([^"]*)":$/) do |organisation_name, roles|
  organisation = Organisation.find_by!(name: organisation_name)

  roles.hashes.each.each do |hash|
    role = create(:role, name: hash[:name])
    create(:organisation_role, organisation:, role:)
  end
end

When(/^I visit the "([^"]*)" "([^"]*)" page$/) do |organisation_name, page|
  organisation = Organisation.find_by!(name: organisation_name)

  visit admin_organisation_path(organisation)

  within ".app-c-secondary-navigation__list" do
    click_link page
  end
end

When(/^I close the organisation "(.*?)", superseding it with the organisation "(.*?)"$/) do |org_name, superseding_org_name|
  organisation = Organisation.find_by!(name: org_name)
  visit edit_admin_organisation_path(organisation.slug)
  choose "Closed"
  select "Replaced", from: "Reason for closure"
  select superseding_org_name, from: "Superseding organisations"
  click_on "Save"
end

Then(/^I can see that the organisation "(.*?)" has been superseded with the organisaion "(.*?)"$/) do |org_name, superseding_org_name|
  organisation = Organisation.find_by!(name: org_name)
  visit admin_organisation_path(organisation)

  expect(page).to have_xpath("//dt[.='Superseding organisation']/following-sibling::dd[.='#{superseding_org_name}']")
end

And(/^I set the order of roles for "([^"]*)" to:$/) do |organisation_name, role_order|
  organisation = Organisation.find_by!(name: organisation_name)

  click_link "Reorder"

  role_order.hashes.each do |hash|
    organisation_role = organisation.organisation_roles.select { |f| f.role.name == hash[:name] }.first
    fill_in "ordering[#{organisation_role.id}]", with: hash[:order]
  end

  click_button "Update order"
end

Then(/^the roles should be in the following order:$/) do |roles|
  role_names = all(".gem-c-summary__block h2").map(&:text)

  roles.hashes.each_with_index do |hash, index|
    expect(hash[:name]).to eq(role_names[index])
  end
end

Given(/^an active topical event called "([^"]*)" exists$/) do |name|
  @topical_event = create(:topical_event, :active, name:)
end

And(/^I visit the the organisation feature page for "([^"]*)"$/) do |name|
  organisation = Organisation.find_by!(name:)
  visit admin_organisation_path(organisation)
  click_link "Features"
end
