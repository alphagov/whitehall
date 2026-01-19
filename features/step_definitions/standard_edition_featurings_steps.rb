And(/^a topical event standard edition called "([^"]*)" exists$/) do |title|
  ConfigurableDocumentType.setup_test_types({ "topical_event" => {
    "key" => "topical_event",
    "title" => "Topical event",
    "schema" => {
      "properties" => {
        "test_attribute" => {
          "title" => "Test Attribute",
          "type" => "string",
        },
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
      "features_enabled": true,
    },
  } })
  @topical_event = create(:standard_edition, configurable_document_type: "topical_event", title:)
end

Given(/^the topical event standard edition is linked to an edition with the title "([^"]*)"$/) do |title|
  create(:publication, :published, title:, topical_event_documents: [@topical_event.document])
end

When(/^I visit the standard edition featuring index page$/) do
  visit features_admin_standard_edition_path(@topical_event)
end

And(/^two featurings exist for the edition$/) do
  topical_event_1 = create(:published_standard_edition, configurable_document_type: "topical_event", title: "Featured Topical Event 1")
  topical_event_2 = create(:published_standard_edition, configurable_document_type: "topical_event", title: "Featured Topical Event 2")
  feature_list = @topical_event.feature_lists.create!(locale: @topical_event.primary_locale)
  create(:feature, feature_list:, document: topical_event_1.document)
  create(:feature, feature_list:, document: topical_event_2.document)
end

And(/^I set the order of the edition featurings to:$/) do |featurings_order|
  click_link "Reorder documents"

  featurings_order.hashes.each do |hash|
    featuring = @topical_event.feature_lists.first.features.select { |f| f.to_s == hash[:title] }.first
    fill_in "ordering[#{featuring.id}]", with: hash[:order]
  end

  click_button "Update order"
end

Then(/^the edition featurings should be in the following order:$/) do |featurings_titles|
  featuring_titles = all("table td:first").map(&:text)

  featurings_titles.hashes.each_with_index do |hash, index|
    featuring = @topical_event.feature_lists.first.features.select { |f| f.to_s == hash[:title] }.first
    expect(featuring.to_s).to eq(featuring_titles[index])
  end
end
