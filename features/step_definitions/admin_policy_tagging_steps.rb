Then(/^I can tag it to some policies$/) do
  select policy_1["title"], from: 'Policies'
  click_button 'Save'
  publication = Publication.last

  assert_path admin_publication_path(publication)
  assert_equal [policy_1["content_id"]], publication.policy_content_ids
end
