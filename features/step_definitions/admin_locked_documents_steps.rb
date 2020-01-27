Given(/^a published locked document titled "([^"]*)"$/) do |title|
  @edition = create(:published_news_article, :with_locked_document, title: title)
end

Given(/^a draft locked document titled "([^"]*)"$/) do |title|
  @edition = create(:draft_news_article, :with_locked_document, title: title)
end

When(/^I visit the admin page for "([^"]*)"$/) do |title|
  @edition = Edition.find_by!(title: title)
  visit admin_edition_path(@edition)
end

Then(/^I can see that I cannot create a new draft$/) do
  new_draft_link = revise_admin_edition_path(@edition)
  refute has_link?("Create new edition to edit", href: new_draft_link)
end

Then(/^I can see that the document cannot be edited$/) do
  edit_link = edit_admin_edition_path(@edition)
  refute has_link?("Edit draft", href: edit_link)
end

And(/^I can see that the document can be edited in Content Publisher$/) do
  content_publisher_base_url = Plek.current.external_url_for('content-publisher')
  content_publisher_link = "#{content_publisher_base_url}/documents/#{@edition.content_id}:#{@edition.primary_locale}"
  assert has_link?("Edit in Content Publisher", href: content_publisher_link)
end

And(/^I can see that the document has been moved to Content Publisher$/) do
  within record_css_selector(@edition) do
    assert_selector ".label-info", text: "Moved to Content Publisher"
    last_cell = find("td:last-child")
    assert last_cell.text, "Moved to Content Publisher"
  end
end
