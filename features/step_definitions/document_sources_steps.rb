Given(/^a draft publication "([^"]*)" with a legacy url "([^"]*)"$/) do |title, old_url|
  publication = create(:draft_publication, title:)
  publication.document.document_sources.create!(url: old_url)
end

Given(/^a draft publication "([^"]*)" with legacy urls "([^"]*)" and "([^"]*)"$/) do |title, old_url1, old_url2|
  publication = create(:draft_publication, title:)
  publication.document.document_sources.create!(url: old_url1)
  publication.document.document_sources.create!(url: old_url2)
end

Then(/^I should see the legacy url "([^"]*)"$/) do |old_url|
  within "#document-sources-section" do
    expect(page).to have_content(old_url)
  end
end

When(/^I add "([^"]*)" as a legacy url to the "([^"]*)" publication$/) do |old_url, title|
  publication = Publication.find_by!(title:)
  visit admin_edition_path(publication)
  click_link "Edit URL redirects"
  fill_in "document_sources", with: old_url
  click_button "Save"
end

When(/^I change the legacy url "([^"]*)" to "([^"]*)" on the "([^"]*)" publication$/) do |old_old_url, new_old_url, title|
  publication = Publication.find_by!(title:)
  visit admin_edition_path(publication)
  within "#document-sources-section" do
    expect(page).to have_content old_old_url
  end
  click_link "Edit URL redirects"
  expect(page).to have_field("document_sources", with: old_old_url)
  fill_in "document_sources", with: new_old_url
  click_button "Save"
end

When(/^I remove the legacy url "([^"]*)" on the "([^"]*)" publication$/) do |_old_url, title|
  publication = Publication.find_by!(title:)
  visit admin_edition_path(publication)
  click_link "Edit URL redirects"
  fill_in "document_sources", with: ""
  click_button "Save"
end

Then(/^I should see that "([^"]*)" has been removed$/) do |old_url|
  within "#document-sources-section" do
    expect(page).not_to have_content old_url
  end
end
