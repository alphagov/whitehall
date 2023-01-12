When(/^I visit the edition show page$/) do
  begin_drafting_document type: "case_study", title: "New edition", previously_published: false
  click_button "Save"
  @edition = Edition.find_by!(title: "New edition")
  visit admin_edition_path(@edition)
end

Then(/^the "([^"]*)" tab is not visible$/) do |tab_name|
  expect(all(".nav-tabs").map(&:text)).not_to have_content tab_name
end

When(/^I visit the edit edition page$/) do
  visit edit_admin_edition_path(@edition)
end

When(/^I add a french translation$/) do
  visit admin_edition_path(@edition)
  click_link "Add translation"

  if using_design_system?
    select "Français", from: "Choose language"
    click_button "Next"
  else
    select "Français", from: "Locale"
    click_button "Add translation"
  end
end

When(/^I add an editorial remark "([^"]*)" to the document$/) do |remark_text|
  @remark_text = remark_text

  visit admin_edition_path(@edition)
  click_link "Notes"
  ensure_path admin_edition_editorial_remarks_path(@edition)
  click_link "Add note"
  ensure_path new_admin_edition_editorial_remark_path(@edition)
  fill_in "Remark", with: @remark_text
  click_button "Add note"
end

Then(/^my editorial remark should be visible on the notes index page$/) do
  ensure_path admin_edition_editorial_remarks_path(@edition)
  expect(page).to have_content(@remark_text)
end

When(/^I add an editorial remark "([^"]*)" to the document "([^"]*)"$/) do |remark_text, document_title|
  @edition = create(:draft_publication, title: document_title)
  @remark_text = remark_text

  visit admin_edition_path(@edition)
  click_link "Add new remark"
  fill_in "Remark", with: @remark_text
  click_button "Submit internal note"
end

Then(/^my editorial remark should be visible with the document$/) do
  ensure_path admin_edition_path(@edition)
  expect(page).to have_selector(".editorial_remark .body", text: @remark_text)
end
