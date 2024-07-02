Given(/^The editionable worldwide organisations feature flag is (enabled|disabled)$/) do |enabled|
  @test_strategy ||= Flipflop::FeatureSet.current.test!
  @test_strategy.switch!(:editionable_worldwide_organisations, enabled == "enabled")
end

Given(/^an editionable worldwide organisation "([^"]*)"$/) do |title|
  worldwide_organisation = create(:editionable_worldwide_organisation, title:)
  worldwide_organisation.main_office = create(:worldwide_office, edition: worldwide_organisation, title: "Main office for #{title}")
end

Given(/^a published editionable worldwide organisation "([^"]*)"$/) do |title|
  worldwide_organisation = create(:editionable_worldwide_organisation, :published, title:)
  worldwide_organisation.main_office = create(:worldwide_office, edition: worldwide_organisation, title: "Main office for #{title}")
end

Given(/^an editionable worldwide organisation "([^"]*)" with offices "([^"]*)" and "([^"]*)"$/) do |title, contact_1_title, contact_2_title|
  worldwide_organisation = create(:editionable_worldwide_organisation, title:)
  worldwide_organisation.add_office_to_home_page!(create(:worldwide_office, edition: worldwide_organisation, contact: create(:contact, title: contact_1_title)))
  worldwide_organisation.add_office_to_home_page!(create(:worldwide_office, edition: worldwide_organisation, contact: create(:contact, title: contact_2_title)))
end

Given(/^An editionable worldwide organisation "([^"]*)" with home page offices "([^"]*)" and "([^"]*)"$/) do |title, office_1_title, office_2_title|
  worldwide_organisation = create(:editionable_worldwide_organisation, title:)
  worldwide_organisation.add_office_to_home_page!(create(:worldwide_office, edition: worldwide_organisation, contact: create(:contact, title: "Main office")))
  worldwide_organisation.add_office_to_home_page!(create(:worldwide_office, edition: worldwide_organisation, contact: create(:contact, title: office_1_title)))
  worldwide_organisation.add_office_to_home_page!(create(:worldwide_office, edition: worldwide_organisation, contact: create(:contact, title: office_2_title)))
end

Given(/^an editionable worldwide organisation in draft with a translation in French$/) do
  worldwide_organisation = create(:editionable_worldwide_organisation, translated_into: :fr)
  worldwide_organisation.add_office_to_home_page!(create(:worldwide_office, edition: worldwide_organisation, contact: create(:contact, title: "Main office")))
end

Given(/^an editionable worldwide organisation "([^"]*)" with a "([^"]*)" page$/) do |title, type|
  worldwide_organisation = create(:editionable_worldwide_organisation, title:)
  create(:worldwide_organisation_page, edition: worldwide_organisation, corporate_information_page_type: CorporateInformationPageType.find(type.parameterize))
end

Given(/^an editionable worldwide organisation "([^"]*)" with a "([^"]*)" page and a translation in French$/) do |title, type|
  worldwide_organisation = create(:editionable_worldwide_organisation, title:, translated_into: :fr)
  create(:worldwide_organisation_page, edition: worldwide_organisation, corporate_information_page_type: CorporateInformationPageType.find(type.parameterize))
end

Given(/^a published editionable worldwide organisation "([^"]*)" with a "([^"]*)" page$/) do |title, type|
  worldwide_organisation = create(:published_editionable_worldwide_organisation, title:)
  create(:worldwide_organisation_page, edition: worldwide_organisation, corporate_information_page_type: CorporateInformationPageType.find(type.parameterize))
end

Given(/^a role "([^"]*)" exists$/) do |name|
  create(:role, name:)
end

Given(/^a social media service "([^"]*)" exists$/) do |name|
  create(:social_media_service, name:)
end

When(/^I create a new edition of the "([^"]*)" worldwide organisation$/) do |name|
  worldwide_organisation = EditionableWorldwideOrganisation.latest_edition.find_by!(title: name)
  visit admin_edition_path(worldwide_organisation)
  click_button "Create new edition"
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

When(/^I withdraw the worldwide organisation "([^"]*)" with the explanation "([^"]*)"$/) do |org_name, explanation|
  organisation = EditionableWorldwideOrganisation.find_by(title: org_name)
  visit admin_editionable_worldwide_organisation_path(organisation)
  click_on "Withdraw or unpublish"
  choose "Withdraw: no longer current government policy/activity"
  within ".js-app-view-unpublish-withdraw-form__withdrawal" do
    fill_in "Public explanation", with: explanation
    click_button "Withdraw"
  end

  expect(:withdrawn).to eq(organisation.reload.current_state)
end

When(/^I visit the reorder offices page/) do
  visit admin_worldwide_organisation_worldwide_offices_path(EditionableWorldwideOrganisation.last)
  click_link "Reorder"
end

When(/^I visit the "([^"]*)" tab/) do |tab|
  visit admin_worldwide_organisation_worldwide_offices_path(EditionableWorldwideOrganisation.last)
  click_link tab
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

When(/^I visit the pages tab for the worldwide organisation$/) do
  visit admin_editionable_worldwide_organisation_path(EditionableWorldwideOrganisation.last)
  click_link "Edit draft"
  click_link "Pages"
end

When(/^I remove the French translation from the main document$/) do
  visit admin_editionable_worldwide_organisation_path(EditionableWorldwideOrganisation.last)
  click_link "Delete"
  click_button "Delete translation"
end

When(/^I click the link to create a new page$/) do
  visit admin_editionable_worldwide_organisation_pages_path(EditionableWorldwideOrganisation.last)
  click_link "Create new page"
end

When(/^I click the "([^"]*)" link for the "([^"]*)" page$/) do |link, type|
  visit admin_editionable_worldwide_organisation_pages_path(EditionableWorldwideOrganisation.last)
  page_component = find("h2", text: type).ancestor(".govuk-summary-card__title-wrapper")
  within page_component do
    click_link link
  end
end

When(/^I click the Attachments tab$/) do
  click_link "Attachments"
end

When(/^I submit the confirmation form to delete the "([^"]*)" page$/) do |type|
  worldwide_organisation_page = WorldwideOrganisationPage.last
  expect(page).to have_current_path(confirm_destroy_admin_editionable_worldwide_organisation_page_path(worldwide_organisation_page.edition, worldwide_organisation_page))
  expect(page).to have_content "Are you sure you want to delete \"#{type}\"?"

  click_button "Delete"
end

When(/^I correctly fill out the worldwide organisation page fields for a "([^"]*)" with:$/) do |type, table|
  select type, from: "Type" if has_select?("Type")
  table.rows_hash.each do |field, value|
    fill_in field, with: value
  end

  click_on "Save"
end

When(/^I add a new page translation with a body of "([^"]*)"$/) do |body|
  click_link "Add translation"
  click_button "Next"
  fill_in "Translated body (required)", with: body
  click_button "Save"
end

And(/^I add an associated office, also with a translation in French$/) do
  visit admin_worldwide_organisation_worldwide_offices_path(EditionableWorldwideOrganisation.last)
  click_link "Add translation"
  click_button "Next"
  fill_in "Title (required)", with: "French title"
  click_button "Save"
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

And(/^I add a new translation with a title of "([^"]*)"$/) do |title|
  click_link "Add translation"
  click_button "Next"
  fill_in "Title (required)", with: title
  click_button "Save"
end

And(/^I edit the worldwide organisation "([^"]*)" adding the role of "([^"]*)"$/) do |title, role|
  begin_editing_document(title)
  select role, from: "Roles"
  click_button "Save and go to document summary"
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

Then(/^I should see the main document translation is gone$/) do
  expect(page).to have_text("No translations for this document")
end

Then(/^I should see that the translated office is gone$/) do
  expect(page).not_to have_text("Translated")
end

Then(/^I should see that the translated page with body "([^"]*)" is gone$/) do |body|
  expect(page).not_to have_text("Translated")
  expect(page).not_to have_text(body)
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
  expect(page).not_to have_text("Topic taxonomy tags")
end

Then(/^I should see the Welsh translated title "([^"]*)" for the "([^"]*)" worldwide organisation$/) do |translated_title, title|
  @worldwide_organisation = EditionableWorldwideOrganisation.find_by(title:)

  I18n.with_locale(:cy) do
    expect(@worldwide_organisation.title).to eq(translated_title)
  end
end

Then(/^I should see the "Translated" subheading in the "Offices" tab with my new translation$/) do
  expect(page).to have_text("Translated")
end

Then(/^I should see the "([^"]*)" role has been assigned to the worldwide organisation "([^"]*)"$/) do |role, title|
  @worldwide_organisation = EditionableWorldwideOrganisation.find_by(title:)
  expect(@worldwide_organisation.roles.first.name).to eq(role)
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

Then(/^I should see that the list of pages for the worldwide organisation is empty$/) do
  expect(page).to have_current_path(admin_editionable_worldwide_organisation_pages_path(EditionableWorldwideOrganisation.last))
  expect(page).to have_text("No pages.")
end

Then(/^I should see the "([^"]*)" page on the list of pages with the details:$/) do |type, table|
  expect(page).to have_current_path(admin_editionable_worldwide_organisation_pages_path(EditionableWorldwideOrganisation.last))
  expect(page).to_not have_text("No pages.")

  page_component = find("h2", text: type).ancestor(".govuk-summary-card")
  within page_component do
    table.rows_hash.each do |field, value|
      description = find("dt", text: field).sibling("dd")
      expect(description).to have_text(value)
    end
  end
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

Then(/^The "(.*?)" attachment should have uploaded successfully$/) do |attachment_title|
  expect(page).to have_content("Attachment '#{attachment_title}' uploaded")
end

Then(/^The audit history for the pages should be displayed on the document history page with:$/) do |table|
  visit admin_editionable_worldwide_organisation_path(EditionableWorldwideOrganisation.last)
  click_link("See what’s changed")
  expect(page).to have_text("This page shows changes to the title, summary, body, and pages in this edition. It does not show changes to attachments.")

  page_histories = page.all(".app-view-audit-trail__page-comparison")
  expect(page_histories.count).to be table.raw.count

  table.raw.each_with_index do |row, index|
    page = page_histories[index]
    page_title, previous_summary, new_summary, previous_body, new_body = row

    expect(page).to have_text(page_title)

    expect(page).to have_selector("del", text: previous_summary) if previous_summary.present?
    expect(page).to have_selector("ins", text: new_summary)

    expect(page).to have_selector("del", text: previous_body) if previous_body.present?
    expect(page).to have_selector("ins", text: new_body)
  end
end
