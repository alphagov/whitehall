Given(/^there is a political document from a previous government$/) do
  @previous_government = FactoryGirl.create(:previous_government)
  @edition = FactoryGirl.create(:published_publication, political: true, first_published_at: @previous_government.start_date)
end

Then(/^it should be publicly marked as belonging to the previous government$/) do
  visit public_document_path(@edition)
  assert page.has_css?(".history-status-block", text: @previous_government.name)
end
