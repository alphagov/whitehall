When /^I add an editorial remark "([^"]*)" to the document "([^"]*)"$/ do |remark_text, document_title|
  @document_title = document_title
  @remark_text = remark_text

  create(:draft_publication, title: @document_title)
  visit admin_root_path
  click_link "Documents"
  within(".author_scope") { click_link "by everyone" }
  within(".state") { click_link "all" }
  click_link @document_title
  click_link "Add new remark"
  fill_in "Remark", with: @remark_text
  click_button "Submit remark"
end

Then /^my editorial remark should be visible with the document$/ do
  click_link "Documents"
  within(".author_scope") { click_link "by everyone" }
  within(".state") { click_link "all" }
  click_link @document_title
  assert page.has_css? ".editorial_remark .body", text: @remark_text
end
