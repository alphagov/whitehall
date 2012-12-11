
Given /^a draft publication "([^"]*)" with a legacy url "([^"]*)"$/ do |title, old_url|
  publication = create(:draft_publication, title: title)
  publication.document.create_document_source(url: old_url)
end

Then /^I should see the legacy url "([^"]*)"$/ do |old_url|
  within "#document-sources" do
    assert has_content?(old_url), "should have link to #{old_url}"
  end
end

When /^I add "([^"]*)" as a legacy url to the "([^"]*)" publication$/ do |old_url, title|
  publication = Publication.find_by_title!(title)
  visit admin_edition_path(publication)
  click_link 'Add legacy url'
  fill_in "Legacy URL", with: old_url
  click_button "Save"
end
