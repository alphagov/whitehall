Given(/^a statistics announcement called "(.*?)" exists$/) do |announcement_title|
  @statistics_announcement = create(:statistics_announcement, title: announcement_title)
end

When(/^I announce an upcoming statistics publication called "(.*?)"$/) do |announcement_title|
  organisation = Organisation.first || create(:organisation)
  topic        = Topic.first || create(:topic)

  ensure_path admin_statistics_announcements_path
  click_on "Create announcement"
  select 'Statistics', from: :statistics_announcement_publication_type_id
  fill_in :statistics_announcement_title, with: announcement_title
  fill_in :statistics_announcement_summary, with: "Summary of publication"
  select_date 1.year.from_now.to_s, from: "Release date"
  select organisation.name, from: :statistics_announcement_organisation_id
  select topic.name, from: :statistics_announcement_topic_id

  click_on 'Save announcement'
end

When(/^I draft a document from the announcement$/) do
  visit admin_statistics_announcement_path(@statistics_announcement)
  click_on 'Draft new document'
end

When(/^I save the draft statistics document$/) do
  fill_in "Body", with: "Statistics body text"
  click_on "Save"
end

Then(/^the document fields are pre\-filled based on the announcement$/) do
  assert page.has_css?("input[id=edition_title][value='#{@statistics_announcement.title}']")
  assert page.has_css?("textarea[id=edition_summary]", text: @statistics_announcement.summary)
end

Then(/^the document becomes linked to the announcement$/) do
  assert publication = Publication.last, "No publication found!"
  visit admin_statistics_announcements_path

  within record_css_selector(@statistics_announcement) do
    assert page.has_link? publication.title, href: admin_publication_path(publication)
  end
end

Then(/^I should see the announcement listed on the list of announcements$/) do
  announcement = StatisticsAnnouncement.last
  ensure_path admin_statistics_announcements_path

  assert page.has_content?(announcement.title)
end
