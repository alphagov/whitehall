Given(/^a draft (document|publication|news article|consultation|speech) "([^"]*)"(?: with summary "([^"]*)")? exists$/) do |document_type, title, summary|
  document_type = "publication" if document_type == "document"
  attributes = { title: }
  attributes[:summary] = summary if summary
  create("draft_#{document_class(document_type).name.underscore}".to_sym, attributes)
end

Given(/^a published (publication|news article|consultation|speech|detailed guide) "([^"]*)" exists$/) do |document_type, title|
  create(:government) if Government.first.nil?
  create("published_#{document_class(document_type).name.underscore}".to_sym, title:)
end

Given(/^a published (publication|news article|consultation|speech|detailed guide) "([^"]*)" with locale "([^"]*)" exists$/) do |document_type, title, locale|
  create(:government) if Government.first.nil?
  create("published_#{document_class(document_type).name.underscore}".to_sym, title:, translated_into: [locale.to_sym])
end

Given(/^a published document "([^"]*)" exists$/) do |title|
  create(:published_publication, title:)
end

Given(/^a draft (publication|news article|consultation) "([^"]*)" was produced by the "([^"]*)" organisation$/) do |document_type, title, organisation_name|
  organisation = Organisation.find_by!(name: organisation_name)
  create("draft_#{document_class(document_type).name.underscore}".to_sym, title:, organisations: [organisation])
end

Given(/^a published (publication|news article|consultation) "([^"]*)" was produced by the "([^"]*)" organisation$/) do |document_type, title, organisation_name|
  organisation = Organisation.find_by!(name: organisation_name)
  create("published_#{document_class(document_type).name.underscore}".to_sym, title:, organisations: [organisation])
end

Given(/^a published (publication|news article|consultation) "([^"]*)" exists relating to the (?:world location|international delegation) "([^"]*)"$/) do |document_type, title, world_location_name|
  world_location = WorldLocation.find_by!(name: world_location_name)
  create("published_#{document_class(document_type).name.underscore}".to_sym, title:, world_locations: [world_location])
end

Given(/^a published (publication|news article|consultation) "([^"]*)" exists relating to the (?:world location|international delegation) "([^"]*)" produced (\d+) days ago$/) do |document_type, title, world_location_name, days_ago|
  world_location = WorldLocation.find_by!(name: world_location_name)
  create("published_#{document_class(document_type).name.underscore}".to_sym, title:, first_published_at: days_ago.to_i.days.ago, world_locations: [world_location])
end

Given(/^a submitted (publication|news article|consultation|speech|detailed guide) "([^"]*)" exists$/) do |document_type, title|
  create("submitted_#{document_class(document_type).name.underscore}".to_sym, title:)
end

Given(/^another user edits the (publication|news article|consultation|speech) "([^"]*)" changing the title to "([^"]*)"$/) do |_document_type, original_title, new_title|
  as_user(create(:writer)) do
    Capybara.using_session("another_user") do
      begin_editing_document original_title
      fill_in "Title", with: new_title
      click_button "Save"
    end
  end
end

Given(/^a published (publication|news article|consultation|speech) "([^"]*)" that's the responsibility of:$/) do |document_type, title, table|
  edition = create(:"published_#{document_type}", title:)
  table.hashes.each do |row|
    person = find_or_create_person(row["Person"])
    ministerial_role = find_or_create_ministerial_role(row["Ministerial Role"])
    unless RoleAppointment.for_role(ministerial_role).for_person(person).exists?
      role_appointment = create(:role_appointment, role: ministerial_role, person:)
    end
    edition.role_appointments << role_appointment
  end
end

Given(/^a draft publication "(.*?)" with a file attachment exists$/) do |title|
  @edition = create(:draft_publication, :with_file_attachment, title:)
  @attachment = @edition.attachments.first
end

Given(/^a force published (document|publication|news article|consultation|speech) "([^"]*)" was produced by the "([^"]*)" organisation$/) do |document_type, title, organisation_name|
  organisation = Organisation.find_by!(name: organisation_name)
  document_type = "publication" if document_type == "document"
  edition = create("draft_#{document_class(document_type).name.underscore}".to_sym, title:, organisations: [organisation])
  stub_publishing_api_links_with_taxons(edition.content_id, %w[a-taxon-content-id])
  visit admin_editions_path(state: :draft)
  click_link title
  publish(force: true)
end

When(/^I view the (publication|news article|consultation|speech|document) "([^"]*)"$/) do |_document_type, title|
  click_link title
end

When(/^I visit the list of draft documents$/) do
  visit admin_editions_path(state: :draft)
end

When(/^I visit the list of documents awaiting review$/) do
  visit admin_editions_path(state: :submitted)
end

When(/^I visit the list of published documents$/) do
  visit admin_editions_path(state: :published)
end

When(/^I select the "([^"]*)" edition filter$/) do |edition_type|
  filter_editions_by :type, edition_type
end

When(/^I filter by author "([^"]*)"$/) do |author_name|
  filter_editions_by :author, author_name
end

When(/^I filter by organisation "([^"]*)"$/) do |organisation_name|
  filter_editions_by :organisation, organisation_name
end

When(/^I filter by organisation "(.*?)" with javascript enabled$/) do |organisation_name|
  select_from_chosen(organisation_name, from: "organisation")
end

When(/^I visit the (publication|consultation) "([^"]*)"$/) do |document_type, title|
  edition = document_class(document_type).find_by!(title:)
  visit public_document_path(edition)
end

When(/^I filter by title or slug "(.*?)" with javascript enabled$/) do |title_or_slug|
  within "#title_filter" do
    fill_in("Title or slug", with: title_or_slug)
    click_on "enter"
  end
end

When(/^I preview "([^"]*)"$/) do |title|
  edition = Edition.find_by!(title:)
  visit preview_document_path(edition)
end

When(/^I preview the document$/) do
  click_link "Preview on website"
end

When(/^I view the document$/) do
  visit public_document_path(@document)
end

When("I submit {edition}") do |edition|
  visit_edition_admin edition.title
  click_button "Submit for 2nd eyes"
end

When("I publish {edition}") do |edition|
  visit_edition_admin edition.title
  publish
end

When("someone publishes {edition}") do |edition|
  as_user(create(:departmental_editor)) do
    visit_edition_admin edition.title
    publish(force: true)
  end
end

When("I force publish {edition}") do |edition|
  stub_publishing_api_links_with_taxons(edition.content_id, %w[a-taxon-content-id])
  visit_edition_admin edition.title, :draft
  click_link "Edit draft"
  fill_in_change_note_if_required
  apply_to_all_nations_if_required
  click_button "Save and continue"
  click_button "Update tags"
  publish(force: true)
end

When(/^I save my changes to the (publication|news article|consultation|speech)$/) do |_document_type|
  click_button "Save"
end

When(/^I edit the (publication|news article|consultation) changing the title to "([^"]*)"$/) do |_document_type, new_title|
  fill_in "Title", with: new_title
  click_button "Save"
end

Then("I should see {edition}") do |edition|
  if using_design_system?
    expect(find(".govuk-table")).to have_content edition.title
  else
    expect(page).to have_selector(record_css_selector(edition))
  end
end

Then("I should not see {edition}") do |edition|
  if using_design_system?
    expect(find(".govuk-table")).not_to have_content edition.title
  else
    expect(page).to_not have_selector(record_css_selector(edition))
  end
end

Then("I should see {edition} in the list of announcements") do |edition|
  if using_design_system?
    expect(find(".govuk-table")).to have_content edition.title
  else
    expect(page).to have_selector(record_css_selector(edition))
  end
end

Then("I should see {edition} in the list of draft documents") do |edition|
  visit admin_editions_path

  if using_design_system?
    expect(find(".govuk-table")).to have_content edition.title
  else
    expect(page).to have_selector(record_css_selector(edition))
  end
end

Then("I should see {edition} in the list of submitted documents") do |edition|
  visit admin_editions_path(state: :submitted)

  if using_design_system?
    expect(find(".govuk-table")).to have_content edition.title
  else
    expect(page).to have_selector(record_css_selector(edition))
  end
end

Then("I should see {edition} in the list of published documents") do |edition|
  visit admin_editions_path(state: :published)

  if using_design_system?
    expect(find(".govuk-table")).to have_content edition.title
  else
    expect(page).to have_selector(record_css_selector(edition))
  end
end

Then("{edition} should no longer be listed on the public site") do |edition|
  public_edition_path = public_path_for(edition)
  stub_content_item_from_content_store_for(public_edition_path)
  visit_public_index_for(edition)
  expect(page).to_not have_content(edition.title)
end

Then(/^I should see the conflict between the (publication|policy|news article|consultation|speech) titles "([^"]*)" and "([^"]*)"$/) do |_document_type, new_title, latest_title|
  expect(new_title).to eq(find(".gem-c-title__context").text)
  expect(page).to have_selector(".conflict h2", text: latest_title)
end

Then(/^my attempt to publish "([^"]*)" should fail$/) do |title|
  edition = Edition.latest_edition.find_by!(title:)
  expect(!edition.published?).to be(true)
end

Then(/^my attempt to publish "([^"]*)" should succeed$/) do |title|
  edition = Edition.latest_edition.find_by!(title:)
  expect(edition.published?).to be(true)
end

Then(/^my attempt to save it should fail with error "([^"]*)"/) do |error_message|
  click_button "Save"
  expect(page).to have_selector(
    ".errors li[data-track-category='form-error'][data-track-action$='-error'][data-track-label=\"#{error_message}\"]",
    text: error_message,
  )
end

When(/^I am on the edit page for (.*?) "(.*?)"$/) do |document_type, title|
  document_type = document_type.tr(" ", "_")
  document = document_type.classify.constantize.find_by(title:)
  visit send("edit_admin_#{document_type}_path", document)
end

When(/^I edit the new edition$/) do
  fill_in "Title", with: "New title"
  fill_in "Body", with: "New body"
  click_button "Save"
end

When(/^I check "([^"]*)" adheres to the consultation principles$/) do |title|
  edition = Edition.latest_edition.find_by!(title:)
  edition.read_consultation_principles = true
  edition.save!
end
