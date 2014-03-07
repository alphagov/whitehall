Given(/^a statistical release announcement called "(.*?)" exists$/) do |announcement_title|
  @release_announcement = create(:statistical_release_announcement, title: announcement_title)
end

When(/^I announce an upcoming statistics publication called "(.*?)"$/) do |announcement_title|
  ensure_path admin_root_path
  organisation = Organisation.first || create(:organisation)
  topic        = Topic.first || create(:topic)

  click_on "Announce upcoming statistics release"
  select 'Statistics', from: :statistical_release_announcement_publication_type_id
  fill_in :statistical_release_announcement_title, with: announcement_title
  fill_in :statistical_release_announcement_summary, with: "Summary of publication"
  select_date 1.year.from_now.to_s, from: "Expected release date"
  select organisation.name, from: :statistical_release_announcement_organisation_id
  select topic.name, from: :statistical_release_announcement_topic_id

  click_on 'Make announcement'
end

When(/^I go to draft a statistics document from the announcement$/) do
  ensure_path admin_root_path

  within record_css_selector(@release_announcement) do
    click_on 'Draft document'
  end
end

When(/^I save the draft statistics document$/) do
  fill_in "Body", with: "Statistics release body text"
  click_on "Save"
end

Then(/^the document fields are pre\-filled based on the announcement$/) do
  assert page.has_css?("input[id=edition_title][value='#{@release_announcement.title}']")
  assert page.has_css?("textarea[id=edition_summary]", text: @release_announcement.summary)
end

Then(/^the document becomes linked to the announcement$/) do
  assert publication = Publication.last, "No publication found!"
  ensure_path admin_root_path

  # save_and_open_page
  within record_css_selector(@release_announcement) do
    assert page.has_link? 'View document', href: admin_publication_path(publication)
  end
end

Then(/^I should see "(.*?)" listed as an announced document on my dashboard$/) do |announcement_title|
  ensure_path admin_root_path

  assert page.has_content?(announcement_title)
end
