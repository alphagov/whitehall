Then(/^I should see a link to the preview version of the publication "([^"]*)"$/) do |publication_title|
  publication = Publication.find_by!(title: publication_title)
  visit admin_edition_path(publication)
  expected_preview_url = "https://draft-origin.test.gov.uk/government/publications/#{publication.slug}"

  expect(expected_preview_url).to eq(find("a[target='_blank']")[:href])
end
