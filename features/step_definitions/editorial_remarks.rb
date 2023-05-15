When(/^I add an editorial remark "([^"]*)" to the document "([^"]*)"$/) do |remark_text, document_title|
  @edition = create(:draft_publication, title: document_title)
  @remark_text = remark_text

  visit admin_edition_path(@edition)
  click_link "Add internal note"
  fill_in "Internal note", with: @remark_text
  click_button "Submit internal note"
end

Then(/^my editorial remark should be visible with the document$/) do
  ensure_path admin_edition_path(@edition)
  expect(page).to have_selector(".app-view-editions-editorial-remark__list-item", text: @remark_text)
end
