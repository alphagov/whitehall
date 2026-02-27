def create_configurable_document(title:, locale: "en", summary: nil, body: nil, date_field: nil, street: nil, city: nil, images: nil, list_of_foods: nil)
  if images.nil?
    image = create(:image)
    images = [image]
  end
  defaults = default_content_for_locale(locale)
  I18n.with_locale(locale) do
    create(
      :draft_standard_edition,
      {
        images:,
        title: title,
        summary: summary || defaults[:summary],
        primary_locale: locale,
        block_content: {
          "body" => body || defaults[:body],
          "date_field" => date_field,
          "street" => street,
          "city" => city,
          "list_of_foods" => list_of_foods,
        },
      },
    )
  end
end

def default_block_content_for_locale(locale)
  default_content_for_locale(locale)
    .stringify_keys
    .except("title", "summary")
end

def default_content_for_locale(locale)
  case locale
  when "cy"
    {
      title: "Dogfen Cymraeg",
      summary: "Crynodeb Cymraeg o'r ddogfen.",
      body: "## Rhywfaint o Gymraeg. Dyma gynnwys y corff yn Gymraeg",
      date_field: { "1" => "2025", "2" => "10", "3" => "2" },
      street: "Stryd Bakers",
      city: "Llundain",
      list_of_foods: [
        { food: "Afal" },
        { food: "Oren" },
      ],
    }
  else
    {
      title: "English document",
      summary: "A brief summary of the document.",
      body: "## Some English govspeak. This is the English body content",
      date_field: { "1" => "2025", "2" => "10", "3" => "1" },
      street: "Bakers Street",
      city: "London",
      list_of_foods: [
        { food: "Apple" },
        { food: "Orange" },
      ],
    }
  end
end

Given(/^the configurable document types feature flag is (enabled|disabled)$/) do |enabled|
  @test_strategy ||= Flipflop::FeatureSet.current.test!
  @test_strategy.switch!(:configurable_document_types, enabled == "enabled")
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
    fill_in "edition[block_content][body]", with: "## Some govspeak\n\nThis is the body content"
    fill_in "edition[block_content][date_field][3]", with: "01"
    fill_in "edition[block_content][date_field][2]", with: "11"
    fill_in "edition[block_content][date_field][1]", with: "2011"
    fill_in "edition[block_content][street]", with: "Bakers Street"
    fill_in "edition[block_content][city]", with: "London"
    fill_in "edition[block_content][list_of_foods][0][food]", with: "Apple"
  end
  click_button "Save and go to document summary"
end

When("I upload single and multiple usage images") do
  edition = @standard_edition || StandardEdition.last
  click_link "Edit draft"
  click_link "Images"

  # Upload a lead usage image
  expect(page).to have_css("img[src='#{edition.placeholder_image_url}']") # Lead image shows a placeholder when there is no selection

  within "#uploaded_lead_image_card" do
    click_link "Add"
  end

  lead_image_file = Rails.root.join("test/fixtures/big-cheese.960x640.jpg")
  upload_file(960, 640, "lead", lead_image_file)
  click_button "Save"

  #   Also upload an embeddable image
  embeddable_img_file = Rails.root.join("test/fixtures/minister-of-funk.960x640.jpg")
  upload_file(960, 640, "govspeak_embed", embeddable_img_file)
end

Then("the images are persisted") do
  edition = @standard_edition || StandardEdition.last
  visit admin_standard_edition_path(edition)
  click_link "Edit draft"
  click_link "Images"

  within "#uploaded_lead_image_card" do
    expect(page.find("img")["src"]).to match(/s960_big-cheese.960x640.jpg/)
  end

  within "#uploaded_embeddable_image_list" do
    expect(page.find("img")["src"]).to match(/s960_minister-of-funk.960x640.jpg/)
  end
end

And("the configurable fields on the Document tab are not overwritten") do
  # Get back to the Document tab
  edition = @standard_edition || StandardEdition.last
  visit admin_standard_edition_path(edition)
  click_link "Edit draft"

  # Check the content is still there
  expect(page).to have_field("Body", with: /This is the body content/)
  expect(page).to have_field("Day", with: "1")
  expect(page).to have_field("Month", with: "11")
  expect(page).to have_field("Year", with: "2011")
  expect(page).to have_field(name: "edition[block_content][city]", with: "London")
  expect(page).to have_field(name: "edition[block_content][street]", with: "Bakers Street")
end

Given(/^I have drafted an English configurable document titled "([^"]*)"$/) do |title|
  @standard_edition = create_configurable_document(**default_content_for_locale("en").merge({ title: }))
end

Given(/^a draft configurable document exists$/) do
  @edition = create_configurable_document(**default_content_for_locale("en"))
end

When(/^I publish a submitted draft of a test configurable document titled "([^"]*)"$/) do |title|
  lead_image = create(:image, usage: "lead")
  embeddable_image = create(:image, usage: "govspeak_embed")
  standard_edition = create(
    :submitted_standard_edition,
    {
      images: [lead_image, embeddable_image],
      title: title,
      block_content: default_block_content_for_locale("en"),
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
  expect(page).to have_content("Test configurable document type")
end

Then(/^I can see that the draft edition of "([^"]*)" was published successfully$/) do |title|
  expect(page).to have_content("The document #{title} has been published")
end

And(/^a new draft of "([^"]*)" is created with the correct field values$/) do |title|
  standard_edition = StandardEdition.find_by(title: title)
  visit admin_standard_edition_path(standard_edition)
  click_button "Create new edition"

  expect(page).to have_field(name: "edition[block_content][body]", with: "## Some English govspeak. This is the English body content")
  expect(page).to have_field(name: "edition[block_content][date_field][3]", with: "1")
  expect(page).to have_field(name: "edition[block_content][date_field][2]", with: "10")
  expect(page).to have_field(name: "edition[block_content][date_field][1]", with: "2025")
  expect(page).to have_field(name: "edition[block_content][city]", with: "London")
  expect(page).to have_field(name: "edition[block_content][street]", with: "Bakers Street")
  expect(page).to have_field(name: "edition[block_content][list_of_foods][0][food]", with: "Apple")

  click_link "Images"
  within "#uploaded_lead_image_card" do
    expect(page.find("img")["src"]).to match(standard_edition.images.detect { |i| i.usage == "lead" }.thumbnail)
  end

  within "#uploaded_embeddable_image_list" do
    expect(page.find("img")["src"]).to match(standard_edition.images.detect { |i| i.usage == "govspeak_embed" }.thumbnail)
  end
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
    fill_in "edition[block_content][body]", with: "## Some govspeak\n\nThis is the body content"
    fill_in "edition[block_content][date_field][3]", with: "01"
    fill_in "edition[block_content][date_field][2]", with: "11"
    fill_in "edition[block_content][date_field][1]", with: "2011"
    select "Cymraeg (Welsh)", from: "Language"
  end
  click_button "Save and go to document summary"
end

When(/^I go to add a Welsh translation$/) do
  edition = @standard_edition || StandardEdition.last
  visit edit_admin_edition_translation_path(edition, :cy)
end

Then(/^configured content blocks should appear on the translation page$/) do
  expect(page).to have_field("Body")
  expect(page).to have_field("Day")
  expect(page).to have_field("Month")
  expect(page).to have_field("Year")
  expect(page).to have_field("City")
  expect(page).to have_field("Street")
end

And(/^the Welsh translation fields should be pre-populated with primary locale content$/) do
  content = default_content_for_locale("en")
  expect(page).to have_field("Body", with: content[:body])
  expect(page).to have_field("Year", with: content[:date_field]["1"])
  expect(page).to have_field("Month", with: content[:date_field]["2"])
  expect(page).to have_field("Day", with: content[:date_field]["3"])
  expect(page).to have_field(name: "edition[block_content][city]", with: "London")
  expect(page).to have_field(name: "edition[block_content][street]", with: "Bakers Street")
end

And(/^I should see the original English content in "original text" sections$/) do
  expect(page).to have_css(".app-c-translated-input__english-translation")
  expect(page).to have_css(".app-c-translated-textarea__english-translation")

  expect(page).to have_css(".app-c-govspeak-editor")

  expect(page).to have_css(".govuk-details", text: "Primary locale content for Body")
end

Then(/^when I set the Welsh translations$/) do
  content = default_content_for_locale("cy")
  fill_in "Translated title (required)", with: content[:title]
  fill_in "Translated summary (required)", with: content[:summary]
  fill_in "Body", with: content[:body]
  fill_in "edition[block_content][date_field][3]", with: content[:date_field]["3"]
  fill_in "edition[block_content][date_field][2]", with: content[:date_field]["2"]
  fill_in "edition[block_content][date_field][1]", with: content[:date_field]["1"]
  fill_in "edition[block_content][street]", with: content[:street]
  fill_in "edition[block_content][city]", with: content[:city]
  click_button "Save"
end

Then(/^the Welsh translations should have persisted$/) do
  edition = @standard_edition || StandardEdition.last
  visit edit_admin_edition_translation_path(edition, :cy)

  content = default_content_for_locale("cy")
  expect(page).to have_field("Translated title (required)", with: content[:title])
  expect(page).to have_field("Translated summary (required)", with: content[:summary])
  expect(page).to have_field("Body", with: content[:body])
  expect(page).to have_field("Year", with: content[:date_field]["1"])
  expect(page).to have_field("Month", with: content[:date_field]["2"])
  expect(page).to have_field("Day", with: content[:date_field]["3"])
  expect(page).to have_field(name: "edition[block_content][street]", with: content[:street])
  expect(page).to have_field(name: "edition[block_content][city]", with: content[:city])
end

Given(/^I have published an English document with a Welsh translation$/) do
  @standard_edition = create(
    :published_standard_edition,
    {
      title: default_content_for_locale("en")[:title],
      summary: default_content_for_locale("en")[:summary],
      block_content: default_block_content_for_locale("en"),
    },
  )
  I18n.with_locale("cy") do
    @standard_edition.translations.create!(
      locale: "cy",
      title: default_content_for_locale("cy")[:title],
      summary: default_content_for_locale("cy")[:summary],
      block_content: default_block_content_for_locale("cy"),
    )
  end
end

When(/^I create a new draft and visit the Welsh translation$/) do
  edition = @standard_edition || StandardEdition.last
  visit admin_standard_edition_path(edition)
  click_button "Create new edition"
  choose "No – it’s a minor edit that does not change the meaning"
  click_button "Save and go to document summary"
  @standard_edition = StandardEdition.last # Update to the new draft edition
end

And(/^the language of the document should be Welsh$/) do
  expect(page).to have_content("Primary language Cymraeg (Welsh)")
end

Given("the test configurable document type group is defined") do
  type_definitions = JSON.parse(File.read(Rails.root.join("features/fixtures/test_configurable_document_type_group.json")))
  types = {}
  type_definitions.each do |type_definition|
    types[type_definition["key"]] = type_definition
  end
  ConfigurableDocumentType.setup_test_types(types)
end

And(/^I have created a new "(.+)" draft$/) do |document_type|
  @standard_edition = create(
    :draft_standard_edition,
    {
      configurable_document_type: document_type,
      title: default_content_for_locale("en")[:title],
      summary: default_content_for_locale("en")[:summary],
      block_content: default_block_content_for_locale("en"),
    },
  )
end

Then(/^I should see a '(.+)' link in the '(.+)' row$/) do |link_text, row_text|
  edition = @standard_edition || StandardEdition.last
  visit admin_standard_edition_path(edition)
  within(".govuk-summary-list__row", text: row_text) do
    expect(page).to have_link(link_text)
    @link = page.find_link(link_text)
  end
end

Then("clicking it should take me to a form listing the document types I can switch to") do
  @link.click
  expect(page).to have_content("Change document type")
  expect(page).to have_content("Test configurable document type two")
end

Then("choosing a document type should take me to a preview page summarising the changes") do
  choose "Test configurable document type two"
  click_button "Next"
  expect(page).to have_content("Review document type change")
  expect(page).to have_content("Document fields")
  expect(page).to have_content("Associations")
end

Then(/when I click "(.+)"/) do |button_text|
  click_button button_text
end

Then("the document type should have updated") do
  within(".gem-c-success-alert") do
    expect(page).to have_content("Document type changed successfully")
  end

  expect(page).to have_content("Test configurable document type two")
end
