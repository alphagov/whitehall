def unwithdraw_publication
  visit admin_edition_path(@publication)

  click_link "Unwithdraw"
  click_button "Unwithdraw"

  @latest_live_edition = @publication.document.live_edition

  expect(:superseded).to eq(@publication.reload.current_state)
  expect(:published).to eq(@latest_live_edition.current_state)
end

When(/^I unwithdraw the publication$/) do
  @publication = Publication.last
  unwithdraw_publication
end

Given("it was subsequently unwithdrawn") do
  last_withdrawal = Unpublishing.where(unpublishing_reason_id: UnpublishingReason::Withdrawn.id).last
  @publication = last_withdrawal.edition
  unwithdraw_publication
end

Then(/^I should be redirected to the latest edition of the publication$/) do
  expect(page).to have_current_path(admin_edition_path(@latest_live_edition))
end
