And(/^a topical event standard edition called "([^"]*)" exists$/) do |title|
  topical_event_hash = { "topical_event" => {
    "key" => "topical_event",
    "title" => "Topical event",
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
  } }
  news_story_hash = build_configurable_document_type("news_story", {
    "key" => "news_story",
    "title" => "News story",
    "associations" => [],
  })
  press_release_hash = build_configurable_document_type("press_release", {
    "key" => "press_release",
    "title" => "Press release",
    "associations" => [],
  })

  ConfigurableDocumentType.setup_test_types(topical_event_hash.merge(news_story_hash).merge(press_release_hash))

  @topical_event = create(:standard_edition, configurable_document_type: "topical_event", title:)
  @news_story = create(:published_standard_edition, configurable_document_type: "news_story", title: "Featured News Story", topical_event_documents: [@topical_event.document])
  @press_release = create(:published_standard_edition, configurable_document_type: "press_release", title: "Featured Press Release", topical_event_documents: [@topical_event.document])
end

Given(/^the topical event standard edition is linked to an edition with the title "([^"]*)"$/) do |title|
  create(:publication, :published, title:, topical_event_documents: [@topical_event.document])
end

And(/^two featurings exist for the edition$/) do
  topical_event_1 = create(:published_standard_edition, configurable_document_type: "topical_event", title: "Featured Topical Event 1")
  topical_event_2 = create(:published_standard_edition, configurable_document_type: "topical_event", title: "Featured Topical Event 2")
  feature_list = @topical_event.feature_lists.create!(locale: @topical_event.primary_locale)
  create(:feature, feature_list:, document: topical_event_1.document)
  create(:feature, feature_list:, document: topical_event_2.document)
end

When(/^I visit the standard edition featuring index page$/) do
  visit edit_admin_standard_edition_path(@topical_event)
  click_link "Features"
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

And(/^I filter the documents by "([^"]*)"$/) do |filter|
  within "#main-content" do
    click_link "Documents"
    fill_in "Title", with: filter
    click_button "Search"
  end
end

Then(/^I see only "([^"]*)" in the list of documents to feature$/) do |filter|
  within "#documents_tab" do
    expect(find("table tbody th:first").text).to eq filter
    expect(find("table").text).not_to include @press_release.title
  end
end

And(/^I click the "([^"]*)" link$/) do |reset_text|
  click_link reset_text
end

Then(/^I see the full list of documents to feature$/) do
  within "#documents_tab" do
    expect(page).to have_content @news_story.title
    expect(page).to have_content @press_release.title
  end
end
