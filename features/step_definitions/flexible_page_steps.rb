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
    fill_in "edition_flexible_page_content_page_title_heading_text", with: title
    fill_in "edition_flexible_page_content_body", with: "## Some govspeak\n\nThis is the body content"
  end
  click_button "Save and go to document summary"
end

When(/^I publish a submitted draft of a test flexible page titled "([^"]*)"$/) do |title|
  submitter = create(:user)
  flexible_page = FlexiblePage.new
  as_user(submitter) do
    flexible_page.flexible_page_type = "test"
    flexible_page.title = title
    flexible_page.state = "submitted"
    flexible_page.document = Document.new
    flexible_page.document.slug = title.parameterize
    flexible_page.flexible_page_content = {
      "page_title" => {
        "heading_text" => title,
        "context" => "Additional context",
      },
      "body" => "Some text",
    }
    flexible_page.creator = submitter
    flexible_page.save!
    stub_publishing_api_links_with_taxons(flexible_page.content_id, %w[a-taxon-content-id])
  end

  visit admin_flexible_page_path(flexible_page)
  click_link "Publish"
  expect(page).to have_content("Once you publish, this document will be visible to the public")
  click_button "Publish"
end

Then(/^I am on the summary page of the draft titled "([^"]*)"$/) do |title|
  expect(page.find("h1")).to have_content(title)
  expect(page).to have_content("Your document has been saved.")
end

Then(/^I can see that the draft edition of "([^"]*)" was published successfully$/) do |title|
  expect(page).to have_content("The document #{title} has been published")
end
