Given(/^The visual editor private beta feature flag is (enabled|disabled)$/) do |enabled|
  @test_strategy ||= Flipflop::FeatureSet.current.test!
  @test_strategy.switch!(:govspeak_visual_editor, enabled == "enabled")
end

When(/^I start creating a new publication$/) do
  visit new_admin_publication_path
end

Then(/^I should see the visual editor instead of the govspeak editor$/) do
  expect(page).to have_selector(".app-c-visual-editor__container")
  expect(page).not_to have_selector(".app-c-govspeak-editor")
end

Then(/^I should see the govspeak editor instead of the visual editor$/) do
  expect(page).to have_selector(".app-c-govspeak-editor")
  expect(page).not_to have_selector(".app-c-visual-editor__container")
end

When(/^I start creating a new HTML attachment for a publication$/) do
  publication = create(:publication)
  visit new_admin_edition_attachment_path(publication, type: "html")
end

Given(/^a draft publication with an HTML attachment "(.*?)" exists$/) do |title|
  html_attachment = create(:html_attachment, title:)
  @publication = create(:publication, attachments: [html_attachment])
end

When(/^I edit the HTML attachment "(.*?)"$/) do |title|
  html_attachment = Attachment.find_by(title:)
  visit edit_admin_edition_attachment_path(@publication, html_attachment)
end
