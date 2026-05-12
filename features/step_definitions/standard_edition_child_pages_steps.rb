def create_parent_standard_edition(state)
  @standard_edition = create(
    "#{state}_standard_edition".to_sym,
    configurable_document_type: "test_type_parent",
    title: "Parent document",
    summary: "This is the parent document",
    primary_locale: "en",
    block_content: {
      "body" => "This is the parent body",
    },
  )
  visit admin_standard_edition_path(@standard_edition)
end

When("I draft a new parent configurable document") do
  create_parent_standard_edition("draft")
end

Then(/^I should see a "(.+)" section on the document summary page$/) do |section_title|
  expect(page).to have_css("h2.gem-c-heading__text", text: section_title)
end

And(/^when I click the link "(.+)"$/) do |link_text|
  click_link(link_text)
end

Then("I am taken to the new child document page") do
  assert_current_path(/^\/government\/admin\/child_documents\/choose_type\?parent_edition_id=#{@standard_edition.id}$/)
end

Then("I see only the relevant child document types") do
  within(".govuk-radios") do
    expect(page).to have_css("label", text: "Test configurable document type child")
    expect(page).to have_css("input[type='radio']", count: 1)
  end
end

Then("when I choose a child document type") do
  choose("Test configurable document type child")
  click_button("Next")
end

Then("I am on the document creation screen") do
  assert_current_path(/^\/government\/admin\/standard-editions\/new\?parent_edition_id=#{@standard_edition.id}&configurable_document_type=topical_event_about_page$/)
end

Then(/^I can see a "(.+)" callout$/) do |callout|
  assert page.has_css?(".govuk-inset-text", text: callout)
end

Then("when I fill in and create the child document") do
  fill_in "Title", with: "Child document"
  fill_in "Summary", with: "This is the child document"
  fill_in "Body", with: "This is the child body"

  click_button "Save and go to document summary"
end

Then("I am taken to the summary page of my child document") do
  @child_edition = StandardEdition.last
  assert_current_path(admin_standard_edition_path(@child_edition))
end

Then("it links back to the parent document") do
  within ".govuk-inset-text" do
    expect(page).to have_link(@standard_edition.title, href: "/government/admin/editions/#{@standard_edition.id}")
  end
end

Given("I have a published parent configurable document") do
  create_parent_standard_edition("published")
end

Then(/^there should be no "(.+)" link$/) do |string|
  expect(page).not_to have_link(string)
end
