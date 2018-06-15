Given(/^there are some statistics$/) do
  # 3 Custom ones are most recent, followed by the extras - largest number most recent

  create :published_statistics, title: "Womble to Wombat population ratios",
                                first_published_at: Time.zone.parse("2011-02-15 12:45:00")

  create :published_national_statistics, title: "2055 beard lengths",
                                         first_published_at: Time.zone.parse("2010-05-01 12:00:00")

  create :published_statistics, title: "Wombat population in Wimbledon Common 2063",
                                first_published_at: Time.zone.parse("2005-02-15 12:45:00")

  (1..40).each do |n|
    create :published_statistics, title: "No. #{n} - More stats",
                                  first_published_at: Time.zone.parse("2000-01-01") + n.days
  end
end

When(/^I visit the statistics index page$/) do
  stub_content_item_from_content_store_for(statistics_path)
  visit statistics_path
end

Then(/^I can see the first page of all the statistics$/) do
  within '.filter-results-summary' do
    assert page.has_content? "43 statistics"
  end
  within '.filter-results' do
    assert page.has_content? "Womble to Wombat population ratios"
    assert page.has_content? "2055 beard lengths"
    assert page.has_content? "Wombat population in Wimbledon Common 2063"
    assert page.has_content? "No. 40 - More stats"
    assert page.has_content? "No. 4 - More stats"
    assert page.has_no_content? "No. 3 - More stats"
    assert_equal 40, page.all(".document-list .document-row").length
  end
end

When(/^I navigate to the next page of statistics$/) do
  within '.filter-results' do
    click_on "Next page"
  end
end

Then(/^I can see the second page of all the statistics$/) do
  assert page.has_no_content? "No. 4 - More stats"
  assert page.has_content? "No. 3 - More stats"
  assert page.has_content? "No. 1 - More stats"
end

When(/^I filter the statistics by keyword, from date and to date$/) do
  within '.filter-form' do
    fill_in "Contains", with: "Wombat"
    fill_in "Published after", with: "2008-01-01"
    fill_in "Published before", with: "2016-01-01"
    click_on "Refresh results"
  end
end

When(/^I should only see statistics matching the given keyword, from date and to date$/) do
  assert page.has_content? "Womble to Wombat population ratios"
  assert_equal 1, page.all(".document-list .document-row").length
end

Given(/^there are some statisics for various departments and topics$/) do
  beard_topic = create(:topic, name: 'Beards')
  wombat_topic = create(:topic, name: 'Wombats')

  beard_org = create(:ministerial_department, name: 'Ministry of Beards')
  wombat_org = create(:ministerial_department, name: 'Wombats of Wimbledon')

  create :published_statistics, title: '2015 Average beard lengths figures',
                                topics: [beard_topic],
                                organisations: [beard_org]

  create :published_statistics, title: 'Average beard lengths of wombat organisations',
                                topics: [beard_topic, wombat_topic],
                                organisations: [wombat_org]

  create :published_statistics, title: 'Wombat population levels',
                                topics: [wombat_topic],
                                organisations: [wombat_org]
end

When(/^I filter the statistics by department and topic$/) do
  within '.filter-form' do
    select "Beards", from: "Policy area"
    select "Wombats of Wimbledon", from: "Department"
    click_on "Refresh results"
  end
end

Then(/^I should only see statistics for the selected departments and topics$/) do
  within('.filter-results') do
    assert page.has_content? "Average beard lengths of wombat organisations"
    assert page.has_no_content? "2015 Average beard lengths figures"
    assert page.has_no_content? "Wombat population levels"
  end
end

Given(/^there is a statistics publication$/) do
  @statistics_publication = create :published_statistics
end

When(/^I click on the first statistics publication$/) do
  within('.filter-results') do
    click_on page.all('h3').first.text
  end
end
