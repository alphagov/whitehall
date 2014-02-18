Then /^I can see some of the latest documents$/ do
  within('#recently-updated') do
    assert page.has_css?('header', text: 'Latest')
    assert page.has_link?('Policy on Topicals')
    assert page.has_link?('Examination of Events')
    assert page.has_link?('Keeping the UK Topical')
  end
end

Then /^I can follow a link to see all documents$/ do
  within('#recently-updated') do
    click_link 'See all'
  end
end

When /^I view the list of all documents for that topical event$/ do
  visit latest_path(topics: [@topical_event])
end

Then /^I see all documents for that topical event with the most recent first$/ do
  docs = sample_document_types_and_titles

  within('.documents-index') do
    assert_equal(page.body.scan('document-row').length, docs.length, "Can't see all the documents for the topical event")
    docs.each do |_, title|
      assert page.has_css?('.document-row', text: title)
    end
  end
end

Then /^I can see a link back to the topical event page$/ do
  topical_event_page = topical_event_path(@topical_event)
  assert page.has_link?(@topical_event.name, topical_event_page)
end

Then /^I can see links to get alerts$/ do
  assert page.has_css?('.feeds')
end
