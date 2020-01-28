Given(/^there are some Welsh statistics$/) do
  # 3 Custom ones are most recent, followed by the extras - largest number most recent

  create :published_statistics, title: "Womble to Wombat population ratios",
                                first_published_at: Time.zone.parse("2011-02-15 12:45:00"),
                                translated_into: :cy

  create :published_national_statistics, title: "2055 beard lengths",
                                         first_published_at: Time.zone.parse("2010-05-01 12:00:00"),
                                         translated_into: :cy

  create :published_statistics, title: "Wombat population in Wimbledon Common 2063",
                                first_published_at: Time.zone.parse("2005-02-15 12:45:00"),
                                translated_into: :cy

  (1..40).each do |n|
    create :published_statistics, title: "No. #{n} - More stats",
                                  first_published_at: Time.zone.parse("2000-01-01") + n.days,
                                  translated_into: :cy
  end
end

When(/^I visit the Welsh statistics index page$/) do
  stub_content_item_from_content_store_for(statistics_path)
  visit statistics_path(locale: :cy)
end

Then(/^I can see the first page of all the statistics$/) do
  within '.filter-results' do
    assert_text "Womble to Wombat population ratios"
    assert_text "2055 beard lengths"
    assert_text "Wombat population in Wimbledon Common 2063"
    assert_text "No. 40 - More stats"
    assert_text "No. 4 - More stats"
    assert_no_text "No. 3 - More stats"
    assert_equal 40, all(".document-list .document-row").length
  end
end

When(/^I navigate to the next page of statistics$/) do
  within '.filter-results' do
    click_on "Next page"
  end
end

Then(/^I can see the second page of all the statistics$/) do
  assert_no_text "No. 4 - More stats"
  assert_text "No. 3 - More stats"
  assert_text "No. 1 - More stats"
end
