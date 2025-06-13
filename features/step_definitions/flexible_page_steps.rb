Given(/^the flexible pages feature flag is (enabled|disabled)$/) do |enabled|
  @test_strategy ||= Flipflop::FeatureSet.current.test!
  @test_strategy.switch!(:flexible_pages, enabled == "enabled")
end

Given(/^the test flexible page type is defined$/) do
  type_definition = JSON.parse(File.read(Rails.root.join("features/fixtures/test_flexible_page_type.json")))
  FlexiblePageType.setup_test_types({ "test" => type_definition })
end

When(/^I draft a new "([^"]*)" flexible page titled "([^"]*)"$/) do |flexible_page_type, title|
  create(:organisation) if Organisation.count.zero?
  visit admin_root_path
  find("li.app-c-sub-navigation__list-item a", text: "New document").click
  page.choose("Flexible page")
  click_button("Next")
  page.choose(flexible_page_type)
  click_button("Next")
  within "form" do
    fill_in "edition_title", with: title
  end
  click_button "Save and go to document summary"
end

Then(/^I am on the summary page of the draft titled "([^"]*)"$/) do |title|
  expect(page.find("h1")).to have_content(title)
  expect(page).to have_content("Your document has been saved.")
end
