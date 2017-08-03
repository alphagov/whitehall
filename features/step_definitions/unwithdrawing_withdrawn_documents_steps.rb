When(/^I unwithdraw the publication$/) do
  publication = Publication.last
  visit admin_edition_path(publication)

  click_link 'Unwithdraw'
  click_button 'Unwithdraw'

  @latest_published_edition = publication.document.published_edition

  assert_equal :superseded, publication.reload.current_state
  assert_equal :published, @latest_published_edition.current_state
end

Then(/^I should be redirected to the latest edition of the publication$/) do
  assert_path admin_edition_path(@latest_published_edition)
end
