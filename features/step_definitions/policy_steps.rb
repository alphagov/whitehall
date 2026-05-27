Then(/^I should see a link to the preview version of the publication "([^"]*)"$/) do |publication_title|
  publication = Publication.find_by!(title: publication_title)
  visit admin_edition_path(publication)
  expected_preview_url = %r{\Ahttps://draft-origin\.test\.gov\.uk/government/publications/#{Regexp.escape(publication.slug)}\?cachebust=\d+\z}

  expect(find("a[target='_blank']")[:href]).to match(expected_preview_url)
end
