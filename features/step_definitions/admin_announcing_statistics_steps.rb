Given(/^a statistics announcement called "(.*?)" exists$/) do |announcement_title|
  @statistics_announcement = create(:statistics_announcement, title: announcement_title)
end

When(/^I announce an upcoming statistics publication called "(.*?)"$/) do |announcement_title|
  ensure_path admin_root_path
  organisation = Organisation.first || create(:organisation)
  topic        = Topic.first || create(:topic)

  click_on "Announce upcoming statistics"
  select 'Statistics', from: :statistics_announcement_publication_type_id
  fill_in :statistics_announcement_title, with: announcement_title
  fill_in :statistics_announcement_summary, with: "Summary of publication"
  select_date 1.year.from_now.to_s, from: "Expected release date"
  select organisation.name, from: :statistics_announcement_organisation_id
  select topic.name, from: :statistics_announcement_topic_id

  click_on 'Make announcement'
end

When(/^I go to draft a statistics document from the announcement$/) do
  ensure_path admin_root_path

  within record_css_selector(@statistics_announcement) do
    click_on 'Draft document'
  end
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
  ensure_path admin_root_path

  # save_and_open_page
  within record_css_selector(@statistics_announcement) do
    assert page.has_link? 'View document', href: admin_publication_path(publication)
  end
end

Then(/^I should see "(.*?)" listed as an announced document on my dashboard$/) do |announcement_title|
  ensure_path admin_root_path

  assert page.has_content?(announcement_title)
end
