Given(/^There are some statistical release announcements$/) do
  create :statistical_release_announcement, title: "Womble to Wombat population ratios",
                                            summary: "All populations of wombles and wombats by region",
                                            publication_type_id: PublicationType::Statistics.id,
                                            expected_release_date: "2050-02-15 12:45:00",
                                            display_release_date_override: nil

  create :statistical_release_announcement, title: "2055 beard lengths",
                                            summary: "Beard lengths by region and gender - 2055",
                                            publication_type_id: PublicationType::NationalStatistics.id,
                                            expected_release_date: "2050-05-01 12:00:00",
                                            display_release_date_override: "May to June 2055"

  create :statistical_release_announcement, title: "Wombat population in Wimbledon Common 2063",
                                            summary: "Wombat vs Womble populations in Wimbledon Common for the year 2063",
                                            publication_type_id: PublicationType::Statistics.id,
                                            expected_release_date: "2063-02-15 12:45:00",
                                            display_release_date_override: nil
  (1..40).each do |n|
    create :statistical_release_announcement, title: "Extra release announcement #{n}", expected_release_date: "2100-01-01"
  end
end

When(/^I visit the statistical release announcements page$/) do
  visit statistical_release_announcements_path
end

When(/^I navigate to the next page of statistical release announcements$/) do
  click_on "Next page"
end

Then(/^I can see the first page of all the statistical release announcements$/) do
  assert page.has_content? "Womble to Wombat population ratios"
  assert page.has_content? "2055 beard lengths"
  assert page.has_content? "Wombat population in Wimbledon Common 2063"
  assert page.has_content? "Extra release announcement 1"
  assert page.has_content? "Extra release announcement 37"
  refute page.has_content? "Extra release announcement 38"
  assert_equal 40, page.all(".document-list .document-row").length
end

Then(/^I can see the second page of all the statistical release announcements$/) do
  refute page.has_content? "Extra release announcement 37"
  assert page.has_content? "Extra release announcement 38"
  assert page.has_content? "Extra release announcement 40"
end

When(/^I filter the statistical release announcements by keyword, from_date and to_date$/) do
  within '.filter-form' do
    fill_in "Contains", with: "Wombat"
    fill_in "Published after", with: "2050-01-01"
    fill_in "Published before", with: "2051-01-01"
    click_on "Refresh results"
  end
end

Then(/^I should only see statistical release announcements for those filters$/) do
  assert page.has_content? "Womble to Wombat population ratios"
  assert_equal 1, page.all(".document-list .document-row").length
end

