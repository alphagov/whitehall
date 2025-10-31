def create_test_image
  create(:image)
end

def create_configurable_document(title:, locale: "en", summary: nil, body: nil)
  image = create_test_image
  defaults = default_content_for_locale(locale)
  I18n.with_locale(locale) do
    create(
      :draft_standard_edition,
      {
        configurable_document_type: "test",
        images: [image],
        title: title,
        summary: summary || defaults[:summary],
        primary_locale: locale,
        block_content: {
          "image" => image.image_data.id.to_s,
          "body" => body || defaults[:body],
        },
      },
    )
  end
end

def default_content_for_locale(locale)
  case locale
  when "cy"
    {
      summary: "Crynodeb Cymraeg o'r ddogfen.",
      body: "## Rhywfaint o Gymraeg\n\nDyma gynnwys y corff yn Gymraeg",
    }
  else
    {
      summary: "A brief summary of the document.",
      body: "## Some English govspeak\n\nThis is the English body content",
    }
  end
end

def add_translation(edition, language, title, summary, body)
  visit admin_standard_edition_path(edition)
  click_link "Add translation"
  select language, from: "Choose language"
  click_button "Next"
  fill_in "Translated title (required)", with: title
  fill_in "Translated summary (required)", with: summary
  fill_in "Body", with: body
  click_button "Save"
end

Given(/^the configurable document types feature flag is (enabled|disabled)$/) do |enabled|
  @test_strategy ||= Flipflop::FeatureSet.current.test!
  @test_strategy.switch!(:configurable_document_types, enabled == "enabled")
end

Given(/^the test configurable document type is defined(?: with translations enabled)?$/) do
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
    fill_in "edition_body", with: "## Some govspeak\n\nThis is the body content"
  end
  click_button "Save and go to document summary"
end

Then("when I switch to the Images tab to fill in the other configurable fields") do
  # Pretend we've uploaded an image already
  edition = @standard_edition || StandardEdition.last
  image = create(:image)
  edition.update!(images: [image])

  # Go to the Images tab to select the image
  click_link "Edit draft"
  click_link "Images"

  # Assert that the valueless "No image selected" option is present as the first option, and that no option has been selected yet
  expect(page).to have_select("Image", options: ["No image selected", edition.images.first.filename])
  expect(page).to have_select("Image", selected: nil)

  # Now select the image and save
  select edition.images.first.filename, from: "Image"
  click_button "Save"
end

Then("the configurable fields on the Images tab are persisted") do
  # Get back to the Images tab
  edition = @standard_edition || StandardEdition.last
  visit admin_standard_edition_path(edition)
  click_link "Edit draft"
  click_link "Images"

  # Check the select value is pre-selected
  expect(page).to have_select("Image", selected: edition.images.first.filename)
end

And("the configurable fields on the Document tab are not overwritten") do
  # Get back to the Document tab
  edition = @standard_edition || StandardEdition.last
  visit admin_standard_edition_path(edition)
  click_link "Edit draft"

  # Check the body content is still there
  expect(page).to have_field("Body", with: /This is the body content/)
end

Given(/^I have drafted an English configurable document titled "([^"]*)"$/) do |title|
  @standard_edition = create_configurable_document(title: title, locale: "en")
end

When(/^I publish a submitted draft of a test configurable document titled "([^"]*)"$/) do |title|
  image = create_test_image
  standard_edition = create(
    :submitted_standard_edition,
    {
      configurable_document_type: "test",
      images: [image],
      title: title,
      block_content: {
        "image" => image.image_data.id.to_s,
        "body" => "Some text",
      },
    },
  )
  stub_publishing_api_links_with_taxons(standard_edition.content_id, %w[a-taxon-content-id])
  visit admin_standard_edition_path(standard_edition)
  click_link "Publish"
  expect(page).to have_content("Once you publish, this document will be visible to the public")
  click_button "Publish"
end

Then(/^I am on the summary page of the draft titled "([^"]*)"$/) do |title|
  expect(page).to_not have_css(".govuk-error-summary")
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
  click_link "Images"
  expect(page).to have_select("Image", selected: standard_edition.images.first.filename)
end

When(/^I create a new "([^"]*)" with Welsh as the primary locale titled "([^"]*)"$/) do |configurable_document_type, title|
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
    fill_in "edition_body", with: "## Some govspeak\n\nThis is the body content"
    select "Cymraeg (Welsh)", from: "Language"
  end
  click_button "Save and go to document summary"
end

Given(/^I have drafted a Welsh primary locale configurable document$/) do
  @welsh_edition = create_configurable_document(
    title: "Dogfen Cymraeg",
    locale: "cy",
    summary: "Crynodeb Cymraeg",
    body: "## Govspeak Cymraeg\n\nCynnwys y corff yn Gymraeg",
  )
end

When(/^I add a Welsh translation "([^"]*)"$/) do |welsh_title|
  edition = @standard_edition || StandardEdition.last
  add_translation(
    edition,
    "Cymraeg (Welsh)",
    welsh_title,
    "Crynodeb Cymraeg byr o'r ddogfen.",
    "## Rhywfaint o govspeak Cymraeg\n\nDyma gynnwys y corff yn Gymraeg",
  )
  visit edit_admin_edition_translation_path(edition, :cy)
end

Then(/^configured content blocks should appear on the translation page$/) do
  expect(page).to have_field("Body")
  expect(page).to have_select("Image")
end

And(/^the Welsh translation fields should be pre-populated with primary locale content$/) do
  expect(page).to have_field("Body", with: /govspeak/)
end

And(/^the image selections should be preserved from the primary locale$/) do
  edition = @standard_edition || StandardEdition.last
  expect(page).to have_select("Image", selected: edition.images.first.filename)
end

And(/^I should see the original English content in "original text" sections$/) do
  expect(page).to have_css(".app-c-translated-input__english-translation")
  expect(page).to have_css(".app-c-translated-textarea__english-translation")

  expect(page).to have_css(".app-c-govspeak-editor")

  expect(page).to have_css(".govuk-details", text: "Primary locale content for Body")
end

And(/^the language of the document should be Welsh$/) do
  expect(page).to have_content("Primary language Cymraeg (Welsh)")
end
