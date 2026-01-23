And(/^a topical event called "([^"]*)" exists$/) do |name|
  @topical_event = create(:topical_event, name:)
end

And(/^a topical event standard edition called "([^"]*)" exists$/) do |title|
  ConfigurableDocumentType.setup_test_types({ "topical_event" => {
    "key" => "topical_event",
    "title" => "Test type",
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
      "images_enabled" => false,
      "organisations" => nil,
      "backdating_enabled" => false,
      "history_mode_enabled" => false,
      "translations_enabled" => false,
    },
  } })
  @topical_event = create(:standard_edition, configurable_document_type: "topical_event", title:)
end

Given(/^a topical event called "(.*?)" with summary "([^"]*)" and description "(.*?)"$/) do |name, summary, description|
  @topical_event = create(:topical_event, name:, summary:, description:)
  stub_topical_event_in_content_store(name)
end

When(/^I create a new topical event "([^"]*)" with summary "([^"]*)" and description "([^"]*)"$/) do |name, summary, description|
  create_topical_event_and_stub_in_content_store(name:, summary:, description:)
end

When(/^I create a new topical event "([^"]*)" with summary "([^"]*)", description "([^"]*)" and it ends today$/) do |name, summary, description|
  create_topical_event_and_stub_in_content_store(name:, summary:, description:, start_date: 2.months.ago.to_date.to_s, end_date: Time.zone.today.to_s)
end

Then(/^I should see the topical event "([^"]*)" in the admin interface$/) do |topical_event_name|
  topical_event = TopicalEvent.find_by!(name: topical_event_name)
  visit admin_topical_events_path(topical_event)
  expect(page).to have_selector(".govuk-table__cell", text: topical_event)
end

Given(/^I'm administering a topical event$/) do
  event = create(:topical_event, name: "Name of event")
  stub_topical_event_in_content_store("Name of event")
  visit admin_topical_event_path(event)
end

When(/^I add a page of information about the event$/) do
  click_link "About page"
  click_link "Create new about page"
  fill_in "Name", with: "Page about the event"
  fill_in "Read more link text", with: "Read more about this event"
  fill_in "Summary", with: "Summary"
  fill_in "Body", with: "Body"
  click_button "Save"
end

Then(/^I should be able to edit the event's about page$/) do
  click_link "Edit"
  fill_in "Name", with: "About the event"
  click_button "Save"
end

Then(/^I should see the about page is updated$/) do
  expect(page).to have_text("About page saved")
end

Then(/^I should be able to delete the topical event "([^"]*)"$/) do |name|
  visit admin_topical_events_path
  click_link "Delete #{name}"

  expect { click_button "Delete" }.to change(TopicalEvent, :count).by(-1)
end
