
When(/^I announce an upcomig statistics publication called "(.*?)"$/) do |announcement_title|
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

Then(/^I should see "(.*?)" listed as an announced document on my dashboard$/) do |announcement_title|
  ensure_path admin_root_path

  assert page.has_content?(announcement_title)
end
