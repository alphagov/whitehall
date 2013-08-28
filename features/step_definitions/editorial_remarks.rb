When /^I add an editorial remark "([^"]*)" to the document "([^"]*)"$/ do |remark_text, document_title|
  @edition = create(:draft_publication, title: document_title)
  @remark_text = remark_text

  visit edit_admin_edition_path(@edition)
  click_link "Add new remark"
  fill_in "Remark", with: @remark_text
  click_button "Submit remark"
end

Then /^my editorial remark should be visible with the document$/ do
  ensure_path admin_edition_path(@edition)
  assert page.has_css? ".editorial_remark .body", text: @remark_text
end
