Given(/^The visual editor private beta feature flag is (enabled|disabled)$/) do |enabled|
  @test_strategy ||= Flipflop::FeatureSet.current.test!
  @test_strategy.switch!(:govspeak_visual_editor, enabled == "enabled")
end

When(/^I start creating a new publication$/) do
  visit new_admin_publication_path
end

Then(/^I should see the visual editor instead of the govspeak editor$/) do
  expect(page).to have_selector(".app-c-visual-editor__visual-editor-wrapper", visible: true)
  expect(page).to have_selector(".app-c-visual-editor__govspeak-editor-wrapper", visible: false)
  expect(page).to have_selector(".app-c-govspeak-editor .govuk-inset-text", visible: false)
end

Then(/^I should see the govspeak editor instead of the visual editor$/) do
  expect(page).to have_selector(".app-c-visual-editor__govspeak-editor-wrapper", visible: true)
  expect(page).to have_selector(".app-c-visual-editor__visual-editor-wrapper", visible: false)
  expect(page).to have_selector(".app-c-govspeak-editor .govuk-inset-text", visible: true)
end

Then(/^I should see the govspeak editor$/) do
  # The visual editor component is never rendered
  expect(page).to have_selector(".app-c-govspeak-editor")
  expect(page).not_to have_selector(".app-c-visual-editor__visual-editor-wrapper")
  expect(page).not_to have_selector(".app-c-visual-editor__govspeak-editor-wrapper")
end

Then(/^I should see the visual editor on subsequent edits of the publication$/) do
  click_link "Edit draft"
  expect(page).to have_selector(".app-c-visual-editor__visual-editor-wrapper", visible: true)
  expect(page).to have_selector(".app-c-visual-editor__govspeak-editor-wrapper", visible: false)
  expect(page).to have_content("Any old iron")
end

Then(/^I should see the visual editor on subsequent edits of the HTML attachment$/) do
  click_link "Edit attachment"
  expect(page).to have_selector(".app-c-visual-editor__visual-editor-wrapper", visible: true)
  expect(page).to have_selector(".app-c-visual-editor__govspeak-editor-wrapper", visible: false)
  expect(page).to have_content("Any old iron")
end

Then(/^I should see the govspeak editor on subsequent edits of the publication$/) do
  click_link "Edit draft"
  expect(page).to have_selector(".app-c-govspeak-editor")
  # When the document is marked as exited the visual editor is not rendered at all
  expect(page).not_to have_selector(".app-c-visual-editor__visual-editor-wrapper")
  expect(page).not_to have_selector(".app-c-visual-editor__govspeak-editor-wrapper")
  expect(page).to have_content("Any old iron")
end

Then(/^I should see the govspeak editor on subsequent edits of the HTML attachment$/) do
  click_link "Edit attachment"
  expect(page).to have_selector(".app-c-govspeak-editor")
  # When the document is marked as exited the visual editor is not rendered at all
  expect(page).not_to have_selector(".app-c-visual-editor__visual-editor-wrapper")
  expect(page).not_to have_selector(".app-c-visual-editor__govspeak-editor-wrapper")
  expect(page).to have_content("Any old iron")
end

When(/^I fill in the required fields for publication "(.*?)" in organisation "(.*?)"$/) do |title, organisation_name|
  draft_publication_with_visual_editor(title, organisation_name)
end

And(/^I save and go to document summary$/) do
  click_button "Save and go to document summary"
end

When(/^I start creating a new HTML attachment for publication "(.*?)"$/) do |title|
  @publication = create(:publication, title:, attachments: [])
  visit new_admin_edition_attachment_path(@publication, type: "html")
end

When(/^I fill in the required fields for HTML attachment "(.*?)"$/) do |title|
  fill_in "Title", with: title
  find(".ProseMirror").base.send_keys("Any old iron")
  check "Use manually numbered headings"
end

And(/^I save the HTML attachment$/) do
  click_on "Save"
end

And(/^I exit the visual editor experience$/) do
  click_on "Continue editing in markdown"
end

When(/^I edit a pre-existing publication$/) do
  publication = create(:publication, visual_editor: nil)
  visit edit_admin_publication_path(publication)
end

When(/^I edit a pre-existing HTML attachment$/) do
  publication = create(:publication, attachments: [], visual_editor: nil)
  attachment = create(:html_attachment, attachable: publication, visual_editor: nil)
  visit edit_admin_edition_attachment_path(publication.id, attachment.id)
end

When(/^I update the publication in the govspeak editor$/) do
  fill_in "edition_body", with: "Any old iron"
end

When(/^I update the HTML attachment in the govspeak editor$/) do
  fill_in "attachment_govspeak_content_body", with: "Any old iron"
end

When(/^I update the publication in the visual editor$/) do
  find(".ProseMirror").base.send_keys("Any old iron")
end

When(/^I update the HTML attachment in the visual editor$/) do
  find(".ProseMirror").base.send_keys("Any old iron")
end

When(/^I edit a publication saved with visual editor$/) do
  publication = create(:publication, visual_editor: true)
  visit edit_admin_publication_path(publication)
end

When(/^I edit an HTML attachment saved with visual editor$/) do
  publication = create(:publication, attachments: [], visual_editor: nil)
  attachment = create(:html_attachment, attachable: publication, visual_editor: true)
  visit edit_admin_edition_attachment_path(publication.id, attachment.id)
end

When(/^I edit a publication that has been previously exited$/) do
  publication = create(:publication, visual_editor: false)
  visit edit_admin_publication_path(publication)
end

When(/^I edit an HTML attachment that has been previously exited$/) do
  publication = create(:publication, attachments: [], visual_editor: nil)
  attachment = create(:html_attachment, attachable: publication, visual_editor: false)
  visit edit_admin_edition_attachment_path(publication.id, attachment.id)
end
