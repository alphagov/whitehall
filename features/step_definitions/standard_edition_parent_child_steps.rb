When(/^I manually navigate to the 'new document' screen with a parent_edition_id param set$/) do
  visit "/government/admin/new-document?parent_edition_id=#{@edition.id}"
end

Then(/^the document should be created$/) do
  expect(page).to have_css(".govuk-notification-banner__heading", text: "Your document has been saved")
end

Then(/^I should be on the document summary page for the child document$/) do
  expect(page).to have_current_path(admin_edition_path(Edition.last))
end

When(/^I manually navigate to a 'new document' screen with an invalid parent_edition_id param set$/) do
  create(:organisation) if Organisation.count.zero? # Getting ready for the form
  visit "/government/admin/standard-editions/new?configurable_document_type=test_type&parent_edition_id=-1"
end

When(/^I edit a child document of that edition$/) do
  child_edition = create(:draft_standard_edition)
  ParentChildRelationship.create!(parent_edition: @edition, child_document: child_edition.document)
  visit edit_admin_edition_path(child_edition)
end

Then(/^the document should fail to save$/) do
  expect(Edition.count).to eq(0)
end

Then(/^I should see a banner that displays the current parent edition$/) do
  expect(page).to have_css(".app-c-child-of-banner__part-of", text: "Child of")
  expect(page).to have_css(".app-c-child-of-banner__title", text: @edition.title)
  expect(page).to have_css(".app-c-child-of-banner__link[href='#{admin_edition_path(@edition)}']", text: "Edit child pages")
end

And(/^I should see an error message describing the corrupt parent edition ID$/) do
  expect(page).to have_content("Parent edition must correspond to an existing StandardEdition")
end

When(/^I view the summary page of a child document of that edition$/) do
  child_edition = create(:draft_standard_edition)
  ParentChildRelationship.create!(parent_edition: @edition, child_document: child_edition.document)
  visit admin_edition_path(child_edition)
end

Then(/^I should see the parent edition on the summary page$/) do
  within ".app-view-summary__parent-edition" do
    expect(page).to have_css("h2", text: "Test type")
    expect(page).to have_css("td", text: @edition.title)
    expect(page).to have_css(".govuk-tag", text: /published/i)
  end
end

When(/^I view the summary page of that edition after adding a child document to it$/) do
  @child_edition = create(:draft_standard_edition, title: "Child Edition")
  ParentChildRelationship.create!(parent_edition: @edition, child_document: @child_edition.document)
  visit admin_edition_path(@edition)
end

Then(/^I should see the child document on the summary page$/) do
  within ".app-view-summary__child-documents" do
    expect(page).to have_link("Edit child pages", href: child_pages_admin_standard_edition_path(@edition))
    expect(page).to have_css("td", text: @child_edition.title)
    expect(page).to have_css("td", text: /ago\s+by #{@child_edition.last_author.name}/)
    expect(page).to have_css(".govuk-tag", text: /draft/i)
    expect(page).to have_link(href: admin_edition_path(@child_edition))
  end
end

When(/^I view the summary page of a child document of that edition that has another child document$/) do
  @child_edition = create(:draft_standard_edition, title: "Child Edition")
  @other_child_edition = create(:draft_standard_edition, title: "Other Child Edition")
  ParentChildRelationship.create!(parent_edition: @edition, child_document: @child_edition.document)
  ParentChildRelationship.create!(parent_edition: @edition, child_document: @other_child_edition.document)
  visit admin_edition_path(@child_edition)
end

Then(/^I should see the other child document on the summary page$/) do
  within ".app-view-summary__other-child-documents" do
    expect(page).to have_link("Edit child pages", href: child_pages_admin_standard_edition_path(@edition))
    expect(page).to have_css("td", text: @other_child_edition.title)
    expect(page).to have_css("td", text: /ago\s+by #{@other_child_edition.last_author.name}/)
    expect(page).to have_css(".govuk-tag", text: /draft/i)
    expect(page).to have_link(href: admin_edition_path(@other_child_edition))
  end
end
