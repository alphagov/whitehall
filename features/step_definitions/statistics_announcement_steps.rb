Given(/^there are some statistics announcements$/) do
  create :statistics_announcement, title: "Womble to Wombat population ratios",
                                            summary: "All populations of wombles and wombats by region",
                                            publication_type_id: PublicationType::OfficialStatistics.id,
                                            current_release_date: build(:statistics_announcement_date,
                                                                        release_date: Time.zone.parse("2050-02-15 12:45:00"),
                                                                        precision: StatisticsAnnouncementDate::PRECISION[:exact])

  create :statistics_announcement, title: "2055 beard lengths",
                                            summary: "Beard lengths by region and gender - 2055",
                                            publication_type_id: PublicationType::NationalStatistics.id,
                                            current_release_date: build(:statistics_announcement_date,
                                                                        release_date: Time.zone.parse("2050-05-01 12:00:00"),
                                                                        precision: StatisticsAnnouncementDate::PRECISION[:two_month])

  create :statistics_announcement, title: "Wombat population in Wimbledon Common 2063",
                                            summary: "Wombat vs Womble populations in Wimbledon Common for the year 2063",
                                            publication_type_id: PublicationType::OfficialStatistics.id,
                                            current_release_date: build(:statistics_announcement_date,
                                                                        release_date: Time.zone.parse("2063-02-15 12:45:00"),
                                                                        precision: StatisticsAnnouncementDate::PRECISION[:one_month])

  (1..40).each do |n|
    create :statistics_announcement, title: "Extra release announcement #{n}",
                                     current_release_date: build(:statistics_announcement_date, release_date: Time.zone.parse("2100-01-01") + n.days)
  end
end

Given(/^there is a cancelled statistics announcement, originally due to be published a few days ago$/) do
  create :cancelled_statistics_announcement,
         title: "Cancelled statistics announcement",
         current_release_date: build(:statistics_announcement_date,
                                     release_date: 5.days.ago,
                                     precision: StatisticsAnnouncementDate::PRECISION[:exact])
end

Given(/^there are some statistics announcements for various departments and topics$/) do
  @department = create :ministerial_department
  @topic = create :topic

  create :statistics_announcement, title: "Announcement for both department and topic", organisation_ids: [@department.id], topics: [@topic]
  create :statistics_announcement, title: "Announcement for department", organisation_ids: [@department.id]
  create :statistics_announcement, title: "Announcement for topic", topics: [@topic]
end

Given(/^there is a statistics announcement$/) do
  @organisation = create :ministerial_department
  @topic = create :topic
  @announcement = create :statistics_announcement,
                         organisation_ids: [@organisation.id],
                         topics: [@topic],
                         statistics_announcement_dates: [build(:statistics_announcement_date, release_date: 1.year.from_now, precision: StatisticsAnnouncementDate::PRECISION[:one_month], created_at: 10.days.ago)],
                         current_release_date: build(:statistics_announcement_date_change, release_date: 1.year.from_now + 2.months, change_note: "A change note")
  @announcement.reload # StatisticsAnnouncement doesn't get statistics_announcement_date related stuff right until after reload.
end

When(/^I visit the statistics announcements page$/) do
  visit statistics_announcements_path
end

When(/^I navigate to the next page of statistics announcements$/) do
  click_on "Next page"
end

When(/^I filter the statistics announcements by keyword, from_date and to_date$/) do
  within '.filter-form' do
    fill_in "Contains", with: "Wombat"
    fill_in "Published after", with: "2050-01-01"
    fill_in "Published before", with: "2051-01-01"
    click_on "Refresh results"
  end
end

When(/^I filter the statistics announcements by department and topic$/) do
  within '.filter-form' do
    select @department.name, from: "Department"
    select @topic.name, from: "Policy Area"
    click_on "Refresh results"
  end
end

Then(/^I can see the first page of all the statistics announcements, including the cancelled announcement$/) do
  within '.filter-results-summary' do
    assert page.has_content? "44 release announcements"
  end
  assert page.has_content? "Cancelled statistics announcement"
  assert page.has_content? "Womble to Wombat population ratios"
  assert page.has_content? "2055 beard lengths"
  assert page.has_content? "Wombat population in Wimbledon Common 2063"
  assert page.has_content? "Extra release announcement 1"
  assert page.has_content? "Extra release announcement 37"
  assert page.has_no_content? "Extra release announcement 38"
  assert_equal 41, page.all(".document-list .document-row").length
end

Then(/^I can see the second page of all the statistics announcements$/) do
  assert page.has_no_content? "Extra release announcement 37"
  assert page.has_content? "Extra release announcement 38"
  assert page.has_content? "Extra release announcement 40"
end

Then(/^I should only see statistics announcements for those filters$/) do
  assert page.has_content? "Womble to Wombat population ratios"
  assert_equal 1, page.all(".document-list .document-row").length
end

Then(/^I should only see statistics announcements for the selected departments and topics$/) do
  assert page.has_content? "Announcement for both department and topic"
  assert page.has_no_content? "Announcement for department"
  assert page.has_no_content? "Announcement for topic"
end
