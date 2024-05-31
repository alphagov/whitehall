Given(/^Documents exist$/) do
  2.times { create(:document) }
end

When(/^I request a bulk republishing of all documents$/) do
  visit admin_republishing_index_path
  find("#all-documents").click
  fill_in "What is the reason for republishing?", with: "It needs republishing"
  click_button("Confirm republishing")
end

Then(/^I can see that all documents have been queued for republishing$/) do
  expect(page).to have_selector(".gem-c-success-alert", text: "All documents have been queued for republishing")
end

Given(/^Documents with pre-publication editions exist$/) do
  2.times { create(:document, editions: [build(:published_edition), build(:draft_edition)]) }
end

When(/^I request a bulk republishing of all documents with pre-publication editions$/) do
  visit admin_republishing_index_path
  find("#all-documents-with-pre-publication-editions").click
  fill_in "What is the reason for republishing?", with: "It needs republishing"
  click_button("Confirm republishing")
end

Then(/^I can see that all documents with pre-publication editions have been queued for republishing$/) do
  expect(page).to have_selector(".gem-c-success-alert", text: "All documents with pre-publication editions have been queued for republishing")
end

Given(/^Documents with pre-publication editions with HTML attachments exist$/) do
  2.times do
    draft_edition = build(:draft_edition)
    create(:document, editions: [build(:published_edition), draft_edition])
    create(:html_attachment, attachable_type: "Edition", attachable_id: draft_edition.id)
  end
end

When(/^I request a bulk republishing of all documents with pre-publication editions with HTML attachments$/) do
  visit admin_republishing_index_path
  find("#all-documents-with-pre-publication-editions-with-html-attachments").click
  fill_in "What is the reason for republishing?", with: "It needs republishing"
  click_button("Confirm republishing")
end

Then(/^I can see that all documents with pre-publication editions with HTML attachments have been queued for republishing$/) do
  expect(page).to have_selector(".gem-c-success-alert", text: "All documents with pre-publication editions with HTML attachments have been queued for republishing")
end

Given(/^Documents with publicly-visible editions with attachments exist$/) do
  2.times do
    document = create(:document, editions: [build(:published_edition), build(:draft_edition)])
    create(:attachment, attachable_type: "Edition", attachable_id: document.live_edition.id)
  end
end

When(/^I request a bulk republishing of all documents with publicly-visible editions with attachments$/) do
  visit admin_republishing_index_path
  find("#all-documents-with-publicly-visible-editions-with-attachments").click
  fill_in "What is the reason for republishing?", with: "It needs republishing"
  click_button("Confirm republishing")
end

Then(/^I can see that all documents with publicly-visible editions with attachments have been queued for republishing$/) do
  expect(page).to have_selector(".gem-c-success-alert", text: "All documents with publicly-visible editions with attachments have been queued for republishing")
end

Given(/^Documents with publicly-visible editions with HTML attachments exist$/) do
  2.times do
    document = create(:document, editions: [build(:published_edition), build(:draft_edition)])
    create(:html_attachment, attachable_type: "Edition", attachable_id: document.live_edition.id)
  end
end

When(/^I request a bulk republishing of all documents with publicly-visible editions with HTML attachments$/) do
  visit admin_republishing_index_path
  find("#all-documents-with-publicly-visible-editions-with-html-attachments").click
  fill_in "What is the reason for republishing?", with: "It needs republishing"
  click_button("Confirm republishing")
end

Then(/^I can see that all documents with publicly-visible editions with HTML attachments have been queued for republishing$/) do
  expect(page).to have_selector(".gem-c-success-alert", text: "All documents with publicly-visible editions with HTML attachments have been queued for republishing")
end

Given(/^Published organisation "About us" pages exist$/) do
  2.times { create(:about_corporate_information_page) }
end

When(/^I request a bulk republishing of all published organisation "About us" pages$/) do
  visit admin_republishing_index_path
  find("#all-published-organisation-about-us-pages").click
  fill_in "What is the reason for republishing?", with: "It needs republishing"
  click_button("Confirm republishing")
end

Then(/^I can see all published organisation "About us" pages have been queued for republishing$/) do
  expect(page).to have_selector(".gem-c-success-alert", text: "All published organisation 'About us' pages have been queued for republishing")
end
