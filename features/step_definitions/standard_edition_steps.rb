Given(/^the configurable document types feature flag is (enabled|disabled)$/) do |enabled|
  @test_strategy ||= Flipflop::FeatureSet.current.test!
  @test_strategy.switch!(:configurable_document_types, enabled == "enabled")
end

Given(/^the test configurable document type is defined$/) do
  type_definition = JSON.parse(File.read(Rails.root.join("features/fixtures/test_configurable_document_type.json")))
  ConfigurableDocumentType.setup_test_types({ "test" => type_definition })
end

When(/^I draft a new "([^"]*)" configurable document titled "([^"]*)"$/) do |configurable_document_type, title|
  create(:organisation) if Organisation.count.zero?
  visit admin_root_path
  find("li.app-c-sub-navigation__list-item a", text: "New document").click
  page.choose("Standard document")
  click_button("Next")
  page.choose(configurable_document_type)
  click_button("Next")
  expect(page).to have_content("New test")
  within "form" do
    fill_in "edition_title", with: title
    fill_in "edition_summary", with: "A brief summary of the document."
    fill_in "edition_block_content_body", with: "## Some govspeak\n\nThis is the body content"
  end
  click_button "Save and go to document summary"
end

When(/^I publish a submitted draft of a test configurable document titled "([^"]*)"$/) do |title|
  submitter = create(:user)
  image = create(:image)
  standard_edition = StandardEdition.new
  as_user(submitter) do
    standard_edition.configurable_document_type = "test"
    standard_edition.title = title
    standard_edition.summary = "A brief summary of the document."
    standard_edition.images = [image]
    standard_edition.state = "submitted"
    standard_edition.previously_published = false
    standard_edition.document = Document.new
    standard_edition.document.slug = title.parameterize
    standard_edition.block_content = {
      "image" => image.image_data.id.to_s,
      "body" => "Some text",
    }
    standard_edition.creator = submitter
    standard_edition.save!
    stub_publishing_api_links_with_taxons(standard_edition.content_id, %w[a-taxon-content-id])
  end

  visit admin_standard_edition_path(standard_edition)
  click_link "Publish"
  expect(page).to have_content("Once you publish, this document will be visible to the public")
  click_button "Publish"
end

Then(/^I am on the summary page of the draft titled "([^"]*)"$/) do |title|
  expect(page.find("h1")).to have_content(title)
  expect(page).to have_content("Your document has been saved.")
  expect(page).to have_content("Standard edition: Test")
end

Then(/^I can see that the draft edition of "([^"]*)" was published successfully$/) do |title|
  expect(page).to have_content("The document #{title} has been published")
end

And(/^a new draft of "([^"]*)" is created with the correct field values$/) do |title|
  standard_edition = StandardEdition.find_by(title: title)
  visit admin_standard_edition_path(standard_edition)
  click_button "Create new edition"
  expect(page).to have_select("Image", selected: standard_edition.images.first.filename)
end
