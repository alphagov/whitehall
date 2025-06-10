Given(/^the flexible pages feature flag is (enabled|disabled)$/) do |enabled|
  @test_strategy ||= Flipflop::FeatureSet.current.test!
  @test_strategy.switch!(:flexible_pages, enabled == "enabled")
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
    fill_in "edition_flexible_page_content_title_heading_text", with: title
  end
  click_button "Save and go to document summary"
end
