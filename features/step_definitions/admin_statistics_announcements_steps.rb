Given(/^a statistics announcement called "(.*?)" exists$/) do |announcement_title|
  @statistics_announcement = create(:statistics_announcement, title: announcement_title)
end

Given(/^a draft statistics publication called "(.*?)"$/) do |title|
  @statistics_publication = create(
    :publication,
    :draft,
    access_limited: false,
    publication_type_id: PublicationType::OfficialStatistics.id,
    title:,
  )
end

Given(/^there is a statistics announcement by my organisation$/) do
  @organisation_announcement = create(:statistics_announcement, organisation_ids: [@user.organisation.id])
end

Given(/^there are statistics announcements by my organisation$/) do
  @past_announcement = create(
    :statistics_announcement,
    organisation_ids: [@user.organisation.id],
    current_release_date: create(:statistics_announcement_date, release_date: 1.day.ago),
    publication: create(:draft_statistics),
  )

  @future_announcement = create(
    :statistics_announcement,
    organisation_ids: [@user.organisation.id],
    current_release_date: create(:statistics_announcement_date, release_date: 1.week.from_now),
  )
end

Given(/^there are statistics announcements by my organisation that are unlinked to a publication$/) do
  @past_announcement = create(
    :statistics_announcement,
    organisation_ids: [@user.organisation.id],
    current_release_date: create(:statistics_announcement_date, release_date: 1.day.ago),
  )

  @tomorrow_announcement = create(
    :statistics_announcement,
    organisation_ids: [@user.organisation.id],
    current_release_date: create(:statistics_announcement_date, release_date: 1.day.from_now),
  )

  @next_week_announcement = create(
    :statistics_announcement,
    organisation_ids: [@user.organisation.id],
    current_release_date: create(:statistics_announcement_date, release_date: 1.week.from_now),
  )

  @next_year_announcement = create(
    :statistics_announcement,
    organisation_ids: [@user.organisation.id],
    current_release_date: create(:statistics_announcement_date, release_date: 1.year.from_now),
  )
end

When(/^I view the statistics announcements index page$/) do
  visit admin_statistics_announcements_path
end

Given(/^there is a statistics announcement by another organistion$/) do
  @other_organisation_announcement = create(:statistics_announcement)
end

Given(/^a cancelled statistics announcement exists$/) do
  @statistics_announcement = create(:cancelled_statistics_announcement)
end

Then(/^I should see my organisation's statistics announcements on the statistical announcements page by default$/) do
  visit admin_statistics_announcements_path

  expect(page).to have_selector("tr.statistics_announcement", text: @organisation_announcement.title)
  expect(page).to_not have_selector("tr.statistics_announcement", text: @other_organisation_announcement.title)
end

When(/^I filter statistics announcements by the other organisation$/) do
  select @other_organisation_announcement.organisations.first.name, from: "Organisation"
  click_on "Search"
end

Then(/^I should only see the statistics announcement of the other organisation$/) do
  expect(page).to have_selector("tr.statistics_announcement", text: @other_organisation_announcement.title)
  expect(page).to_not have_selector("tr.statistics_announcement", text: @organisation_announcement.title)
end

When(/^I link the announcement to the publication$/) do
  visit admin_statistics_announcement_path(@statistics_announcement)

  if using_design_system?
    click_on "Add existing document"
  else
    click_on "connect an existing draft"
  end

  fill_in "title", with: "statistics"
  click_on "Search"

  if using_design_system?
    find(".govuk-link", text: "Connect").click
  else
    find("li.ui-menu-item").click
  end
end

Then(/^I should see that the announcement is linked to the publication$/) do
  expect(page).to have_current_path(admin_statistics_announcement_path(@statistics_announcement))
  if using_design_system?
    expect(page).to have_content("Announcement updated successfully")
    expect(page).to have_link("Change connected document", href: admin_statistics_announcement_publication_index_path(@statistics_announcement))
    expect(page).to_not have_link("Add existing document", href: admin_statistics_announcement_publication_index_path(@statistics_announcement))
    expect(page).to_not have_link("create new document", href: new_admin_publication_path(statistics_announcement_id: @statistics_announcement))
    expect(page).to have_content(@statistics_publication.title.to_s)
    expect(page).to have_link("View", href: admin_statistics_announcement_publication_index_path(@statistics_announcement))
  else
    expect(page).to have_content(
      "Announcement connected to draft document #{@statistics_publication.title}",
      normalize_ws: true,
    )
  end
end

When(/^I announce an upcoming statistics publication called "(.*?)"$/) do |announcement_title|
  organisation = Organisation.first || create(:organisation)

  ensure_path admin_statistics_announcements_path
  click_on "Create announcement"
  choose "statistics_announcement_publication_type_id_5" # Statistics
  fill_in :statistics_announcement_title, with: announcement_title
  fill_in :statistics_announcement_summary, with: "Summary of publication"
  if using_design_system?
    within "#statistics_announcement_current_release_date_release_date" do
      fill_in_date_and_time_field(1.year.from_now.to_s)
    end
    select organisation.name, from: :statistics_announcement_organisations
  else
    select_date 1.year.from_now.to_s, from: "Release date"
    select organisation.name, from: :statistics_announcement_organisation_ids
  end

  click_on "Publish announcement"
end

When(/^I draft a document from the announcement$/) do
  visit admin_statistics_announcement_path(@statistics_announcement)
  if using_design_system?
    click_on "create new document"
  else
    click_on "Draft new document"
  end
end

When(/^I save the draft statistics document$/) do
  fill_in "Body", with: "Statistics body text"
  check "Applies to all UK nations"
  click_on "Save"
end

When(/^I change the release date on the announcement$/) do
  visit admin_statistics_announcement_path(@statistics_announcement)

  if using_design_system?
    click_on "Change dates"

    within "#statistics_announcement_date_change_release_date" do
      fill_in_date_and_time_field("14-Dec-#{Time.zone.today.year.next} 09:30")
    end

    choose "Exact date (confirmed)"
    click_on "Publish date"
  else
    click_on "Change release date"
    select_datetime "14-Dec-#{Time.zone.today.year.next} 09:30", from: "Release date"
    check "Confirmed date?"
    choose "Exact"

    click_on "Publish change of date"
  end
end

When(/^I search for announcements containing "(.*?)"$/) do |keyword|
  visit admin_statistics_announcements_path
  fill_in "Title or slug", with: keyword
  select "All organisations", from: "Organisation"
  click_on "Search"
end

When(/^I cancel the statistics announcement$/) do
  visit admin_statistics_announcement_path(@statistics_announcement)

  click_on "Cancel statistics release"
  if using_design_system?
    fill_in "Reason for cancellation", with: "Cancelled because: reasons"
  else
    fill_in "Official reason for cancellation", with: "Cancelled because: reasons"
  end

  click_on "Publish cancellation"
end

When(/^I change the cancellation reason$/) do
  visit admin_statistics_announcement_path(@statistics_announcement)

  click_on "Edit cancellation reason"

  if using_design_system?
    fill_in "Reason for cancellation", with: "Updated cancellation reason"
  else
    fill_in "Official reason for cancellation", with: "Updated cancellation reason"
  end

  click_on "Update cancellation reason"
end

Then(/^I should see the updated cancellation reason$/) do
  expect(page).to have_current_path(admin_statistics_announcement_path(@statistics_announcement))

  expect(page).to have_content("Statistics release cancelled")
  expect(page).to have_content("Updated cancellation reason")
end

Then(/^I should see that the statistics announcement has been cancelled$/) do
  ensure_path admin_statistics_announcement_path(@statistics_announcement)
  if using_design_system?
    expect(page).to have_content("Announcement has been cancelled")
  else
    expect(page).to have_content("Statistics release cancelled")
    expect(page).to have_content("Cancelled because: reason")
  end
end

Then(/^the document fields are pre-filled based on the announcement$/) do
  expect(page).to have_selector("textarea[id=edition_title]", text: @statistics_announcement.title)
  expect(page).to have_selector("textarea[id=edition_summary]", text: @statistics_announcement.summary)
end

Then(/^the document becomes linked to the announcement$/) do
  publication = Publication.last
  visit admin_statistics_announcements_path(organisation_id: "")

  within record_css_selector(@statistics_announcement) do
    expect(page).to have_link(publication.title, href: admin_publication_path(publication))
  end
end

Then(/^I should see the announcement listed on the list of announcements$/) do
  announcement = StatisticsAnnouncement.last
  ensure_path admin_statistics_announcements_path

  expect(page).to have_content(announcement.title)
end

Then(/^I should (see|only see) a statistics announcement called "(.*?)"$/) do |single_or_multiple, title|
  expect(page).to have_selector("tr.statistics_announcement", count: 1) if single_or_multiple == "only see"
  expect(page).to have_selector("tr.statistics_announcement", text: title)
end

Then(/^the new date is reflected on the announcement$/) do
  expect(page).to have_content("14 December #{Time.zone.today.year.next} 9:30am (confirmed)")
end

Then(/^I should be able to filter both past and future announcements$/) do
  visit admin_statistics_announcements_path

  select "Future releases", from: "Release date"
  click_on "Search"

  expect(page).to have_selector("tr.statistics_announcement", text: @future_announcement.title)
  expect(page).to_not have_selector("tr.statistics_announcement", text: @past_announcement.title)

  select "Past announcements", from: "Release date"
  click_on "Search"

  expect(page).to have_selector("tr.statistics_announcement", text: @past_announcement.title)
  expect(page).to_not have_selector("tr.statistics_announcement", text: @future_announcement.title)
end

Then(/^I should be able to filter only the unlinked announcements$/) do
  visit admin_statistics_announcements_path

  select "All announcements", from: "Release date"
  check :unlinked_only
  click_on "Search"

  expect(page).to have_selector("tr.statistics_announcement", text: @future_announcement.title)
  expect(page).to_not have_selector("tr.statistics_announcement", text: @past_announcement.title)
end

Then(/^I should see a warning that there are upcoming releases without a linked publication$/) do
  expect(page).to have_content("2 imminent releases need a publication")
end

Then(/^I should be able to view these upcoming releases without a linked publication$/) do
  click_on "2 imminent releases"

  expect(page).to have_selector("tr.statistics_announcement", text: @tomorrow_announcement.title)
  expect(page).to have_selector("tr.statistics_announcement", text: @next_week_announcement.title)
  expect(page).to_not have_selector("tr.statistics_announcement", text: @past_announcement.title)
  expect(page).to_not have_selector("tr.statistics_announcement", text: @next_year_announcement.title)
end

When(/^I unpublish the statistics announcement$/) do
  visit admin_statistics_announcement_path(@statistics_announcement)

  click_on "Unpublish announcement"
  fill_in "Redirect to URL", with: "http://www.dev.gov.uk/example"

  if using_design_system?
    click_on "Unpublish announcement"
  else
    click_on "Unpublish"
  end
end

Then(/^I should see the unpublish statistics announcement banner$/) do
  ensure_path admin_statistics_announcements_path

  expect(page).to have_content("Unpublished statistics announcement: #{@statistics_announcement.title}")
end

Then(/^I should see no statistic announcements$/) do
  expect(page).to have_content("No future statistics announcements found")
end
