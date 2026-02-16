And(/^a featurable standard edition called "([^"]*)" exists$/) do |title|
  ConfigurableDocumentType.setup_test_types({ "test_type" => {
    "key" => "test_type",
    "title" => "Test Type",
    "forms" => {
      "documents" => {
        "fields" => {
          "body" => {
            "title" => "Body",
            "description" => "The main content of the page",
            "block" => "govspeak",
          },
        },
      },
    },
    "schema" => {
      "properties" => {
        "test_attribute" => {
          "title" => "Test Attribute",
          "type" => "string",
        },
      },
    },
    "presenters" => {
      "publishing_api" => {
        "details" => {}
      },
    },
    "associations" => [],
    "settings" => {
      "edit_screens" => {
        "document" => %w[test_attribute],
      },
      "base_path_prefix" => "/government/test",
      "publishing_api_schema_name" => "test_article",
      "publishing_api_document_type" => "test_story",
      "rendering_app" => "frontend",
      "images" => {
        "enabled" => false,
      },
      "organisations" => nil,
      "backdating_enabled" => false,
      "history_mode_enabled" => false,
      "translations_enabled" => false,
      "features_enabled" => true,
    },
  } })
  @featurable_edition = create(:standard_edition, configurable_document_type: "test_type", title:)
end

Given(/^the featurable standard edition is linked to an edition with the title "([^"]*)"$/) do |title|
  # Only topical events can be linked through configurable associations at the moment,
  # so we need to use the topical_event_documents association to link the standard edition to another edition.
  # In future, we should make a generic association suitable for both topical events and any other associable document type.
  create(:publication, :published, title:, topical_event_documents: [@featurable_edition.document])
end

And(/^two featurings exist for the edition$/) do
  featured_edition_1 = create(:published_standard_edition, configurable_document_type: "test_type", title: "Featured Edition 1")
  featured_edition_2 = create(:published_standard_edition, configurable_document_type: "test_type", title: "Featured Edition 2")
  feature_list = @featurable_edition.feature_lists.create!(locale: @featurable_edition.primary_locale)
  create(:feature, feature_list:, document: featured_edition_1.document)
  create(:feature, feature_list:, document: featured_edition_2.document)
end

When(/^I visit the standard edition featuring index page$/) do
  visit edit_admin_standard_edition_path(@featurable_edition)
  click_link "Features"
end

And(/^I set the order of the edition featurings to:$/) do |featurings_order|
  click_link "Reorder documents"

  featurings_order.hashes.each do |hash|
    featuring = @featurable_edition.feature_lists.first.features.select { |f| f.to_s == hash[:title] }.first
    fill_in "ordering[#{featuring.id}]", with: hash[:order]
  end

  click_button "Update order"
end

Then(/^the edition featurings should be in the following order:$/) do |featurings_titles|
  featuring_titles = all("table td:first").map(&:text)

  featurings_titles.hashes.each_with_index do |hash, index|
    featuring = @featurable_edition.feature_lists.first.features.select { |f| f.to_s == hash[:title] }.first
    expect(featuring.to_s).to eq(featuring_titles[index])
  end
end
