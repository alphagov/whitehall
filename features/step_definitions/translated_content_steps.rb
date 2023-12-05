Given(/^a worldwide organisation that is translated exists$/) do
  world_location = create(:world_location, active: true)
  worldwide_organisation = create(
    :worldwide_organisation,
    world_locations: [world_location],
    name: "en-organisation",
    translated_into: { fr: { name: "fr-organisation" } },
  )
  create(
    :about_corporate_information_page,
    organisation: nil,
    worldwide_organisation:,
    summary: "en-summary",
    translated_into: { fr: { summary: "fr-summary" } },
  )
end

When(/^I visit the world organisation that is translated$/) do
  visit LegacyWorldwideOrganisation.last.public_path(locale: "fr")
end

Then(/^I should see the translation of that world organisation$/) do
  expect(page).to have_selector(".worldwide-org-summary", text: "fr-summary")
end

Given(/^I have drafted a translatable document "([^"]*)"$/) do |title|
  begin_drafting_document type: "case_study", title:, previously_published: false
  click_button "Save"
end

Given(/^I have drafted a translatable document "([^"]*)" with a french translation with the title "([^"]*)"$/) do |title, translation_title|
  create(:draft_case_study, title:, translated_into: [:fr])
  edition = Edition.find_by!(title:)
  I18n.with_locale :fr do
    edition.title = translation_title
    edition.save!
  end
end

When(/^I add a french translation "([^"]*)" to the "([^"]*)" document$/) do |french_title, english_title|
  visit admin_edition_path(Edition.find_by!(title: english_title))
  click_link "Add translation"

  select "Français", from: "Choose language"
  click_button "Next"
  fill_in "Translated title (required)", with: french_title
  fill_in "Translated summary (required)", with: "French summary"
  fill_in "Translated body (required)", with: "French body"
  click_button "Save"
end

When(/^I edit "([^"]*)"'s french translation's title to "([^"]*)"$/) do |english_title, new_title|
  edition = Edition.find_by!(title: english_title)
  visit admin_edition_path(edition)
  find("a[href='#{edit_admin_edition_translation_path(edition, :fr)}']").click

  fill_in "Translated title (required)", with: new_title
  click_button "Save"
end

When(/^I delete "([^"]*)"'s french translation$/) do |english_title|
  edition = Edition.find_by!(title: english_title)
  visit admin_edition_path(edition)
  find("a[href='#{confirm_destroy_admin_edition_translation_path(edition, :fr)}']").click

  click_button "Delete translation"
end

Then(/^I should see on the admin edition page that "([^"]*)" has a french translation "([^"]*)"$/) do |english_title, french_title|
  visit admin_edition_path(Edition.find_by!(title: english_title))
  expect(page).to have_content(french_title)
end

Then(/^I should see on the admin edition page that "([^"]*)"'s french translation "([^"]*)" has been deleted$/) do |english_title, french_title|
  visit admin_edition_path(Edition.find_by!(title: english_title))
  expect(page).not_to have_content(french_title)
end

Given(/^the organisation "(.*?)" is translated into Welsh and has a contact "(.*?)"$/) do |organisation_name, contact_title|
  organisation = create(:organisation, name: organisation_name, translated_into: :cy)
  contact = create(
    :contact,
    title: contact_title,
    country: create(:world_location, active: true),
    street_address: "123 The Avenue",
    contactable: organisation,
  )
  create(
    :contact_number,
    contact:,
    label: "English phone",
    number: "0123456789",
  )
end

When(/^I add a welsh translation "(.*?)" to the "(.*?)" contact$/) do |welsh_title, english_title|
  contact = Contact.find_by(title: english_title)
  visit admin_organisation_contacts_path(contact.contactable)
  click_link "Add translation"

  select "Cymraeg", from: "Select language"
  click_button "Next"

  fill_in "Title", with: welsh_title
  fill_in "Recipient", with: "Welsh recipient"
  fill_in "Street address", with: "Welsh street address"
  fill_in "Number", with: "9876543210"
  click_button "Save"
end

Then(/^I should see on the admin organisation contacts page that "(.*?)" has a welsh translation "(.*?)"$/) do |english_title, welsh_title|
  contact = Contact.find_by(title: english_title)
  visit admin_organisation_contacts_path(contact.contactable)

  within all(".govuk-summary-card__title")[1] do
    expect(page).to have_content(welsh_title)
  end
end

Given(/^the world organisation "(.*?)" is translated into French and has an office "(.*?)"$/) do |organisation_name, office_name|
  organisation = create(:worldwide_organisation, name: organisation_name, translated_into: :fr)
  contact = create(
    :contact,
    title: office_name,
    country: create(:world_location, active: true),
    street_address: "123 The Avenue",
  )
  create(:contact_number, contact:, label: "English phone", number: "0123456789")
  create(:worldwide_office, legacy_worldwide_organisation: organisation, contact:)
end

When(/^I add a french translation "(.*?)" to the "(.*?)" office$/) do |french_title, english_title|
  office = Contact.find_by(title: english_title).contactable
  visit admin_legacy_worldwide_organisation_worldwide_offices_path(office.legacy_worldwide_organisation)
  click_link "Add translation"
  select "Français (French)", from: "Select language"
  click_button "Next"
  fill_in "Title (required)", with: french_title
  fill_in "Recipient", with: "French recipient"
  fill_in "Street address", with: "French street address"
  fill_in "Number", with: "9876543210"
  click_button "Save"
end

Then(/^I should see on the admin world organisation offices page that "(.*?)" has a french translation "(.*?)"$/) do |english_title, _french_title|
  office = Contact.find_by(title: english_title).contactable
  visit admin_legacy_worldwide_organisation_translations_path(office.legacy_worldwide_organisation)
  expect(page).to have_content("Français")
end
