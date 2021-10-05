Then(/^I can see some of the latest documents$/) do
  within("#recently-updated") do
    expect(page).to have_selector("header", text: "Latest")
    expect(page).to have_link("Policy on Topicals")
    expect(page).to have_link("Examination of Events")
  end
end

Then(/^I can follow a link to see all documents$/) do
  within("#recently-updated") do
    click_link "See all"
  end
end

When(/^I view the list of all documents for that topical event$/) do
  visit latest_path(topical_events: [@topical_event])
end

Then(/^I see all documents for that topical event with the most recent first$/) do
  docs = sample_document_types_and_titles

  within(".gem-c-document-list") do
    expect(all(".gem-c-document-list__item").length).to eq(docs.length)
    docs.each_value do |title|
      expect(page).to have_selector(".gem-c-document-list__item", text: title)
    end
  end
end

Then(/^I can see a link back to the topical event page$/) do
  topical_event_page = topical_event_path(@topical_event)
  expect(page).to have_link(@topical_event.name, href: topical_event_page)
end

Then(/^I can see links to get alerts$/) do
  expect(page).to have_selector(".feeds")
end
