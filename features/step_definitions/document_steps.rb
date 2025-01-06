Given(/^a draft (document|publication|news article|consultation|speech|call for evidence) "([^"]*)"(?: with summary "([^"]*)")? exists$/) do |document_type, title, summary|
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

Given(/^a document with content ID "([^"]*)" exists$/) do |content_id|
  create(:document, content_id:)
end

Given(/^a draft (publication|news article|consultation) "([^"]*)" was produced by the "([^"]*)" organisation$/) do |document_type, title, organisation_name|
  organisation = Organisation.find_by!(name: organisation_name)
  create("draft_#{document_class(document_type).name.underscore}".to_sym, title:, organisations: [organisation])
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

When(/^I select the "([^"]*)" edition filter$/) do |edition_type|
  filter_editions_by :type, edition_type
end

When(/^I filter by author "([^"]*)"$/) do |author_name|
  filter_editions_by :author, author_name
end

When(/^I filter by organisation "([^"]*)"$/) do |organisation_name|
  filter_editions_by :organisation, organisation_name
end

When("I submit {edition}") do |edition|
  visit_edition_admin edition.title
  click_button "Submit for 2nd eyes"
end

When("I publish {edition}") do |edition|
  stub_publishing_api_links_with_taxons(edition.content_id, %w[a-taxon-content-id])
  visit_edition_admin edition.title
  publish
end

When("I force publish a new edition of {edition}") do |edition|
  stub_publishing_api_links_with_taxons(edition.content_id, %w[a-taxon-content-id])
  visit_edition_admin edition.title
  click_button "Create new edition"
  fill_in_change_note_if_required
  apply_to_all_nations_if_required
  click_button "Save and go to document summary"
  publish(force: true)
end

When("I force publish {edition}") do |edition|
  stub_publishing_api_links_with_taxons(edition.content_id, %w[a-taxon-content-id])
  visit_edition_admin edition.title, :draft
  click_link "Edit draft"
  fill_in_change_note_if_required
  apply_to_all_nations_if_required
  click_button "Save and go to document summary"
  publish(force: true)
end

When(/^I save my changes to the (publication|news article|consultation|speech)$/) do |_document_type|
  click_button "Save"
end

Then("I should see {edition}") do |edition|
  expect(find(".govuk-table")).to have_content edition.title
end

Then("I should not see {edition}") do |edition|
  expect(find(".govuk-table")).not_to have_content edition.title
end

Then("I should see {edition} in the list of draft documents") do |edition|
  visit admin_editions_path

  expect(find(".govuk-table")).to have_content edition.title
end

Then("I should see {edition} in the list of submitted documents") do |edition|
  visit admin_editions_path(state: :submitted)

  expect(find(".govuk-table")).to have_content edition.title
end

Then("I should see {edition} in the list of published documents") do |edition|
  visit admin_editions_path(state: :published)

  expect(find(".govuk-table")).to have_content edition.title
end

Then(/^I should see the conflict between the (publication|policy|news article|consultation|speech) titles "([^"]*)" and "([^"]*)"$/) do |_document_type, new_title, latest_title|
  expect(new_title).to eq(find(".gem-c-title__context").text)
  expect(page).to have_selector(".conflict h2", text: latest_title)
end

When(/^I am on the edit page for (.*?) "(.*?)"$/) do |document_type, title|
  document_type = document_type.tr(" ", "_")
  document = document_type.classify.constantize.where(title:).last
  visit send("edit_admin_#{document_type}_path", document)
end

When(/^I check "([^"]*)" adheres to the consultation principles$/) do |title|
  edition = Edition.latest_edition.find_by!(title:)
  edition.read_consultation_principles = true
  edition.save!
end

When(/^the document hub feature flag is (enabled|disabled)$/) do |document_hub_enabled|
  @test_strategy ||= Flipflop::FeatureSet.current.test!
  @test_strategy.switch!(:document_hub_enabled, document_hub_enabled == "enabled")
end
