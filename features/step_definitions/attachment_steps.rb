def manually_numbered_headings
  if using_design_system?
    "Use manually numbered headings"
  else
    "Manually numbered headings"
  end
end

When(/^I visit the attachments page$/) do
  first(:link, "Attachments").click
end

When(/^the attachment has been uploaded to the asset-manager$/) do
  Attachment.last.attachment_data.uploaded_to_asset_manager!
end

When(/^I start editing the attachments from the .*? page$/) do
  click_on "Modify attachments"
end

When(/^I upload a file attachment with the title "(.*?)" and the file "(.*?)"$/) do |title, fixture_file_name|
  click_on "Upload new file attachment"
  fill_in "Title", with: title
  attach_file "File", Rails.root + "test/fixtures/#{fixture_file_name}"
  click_on "Save"
end

When(/^I upload an html attachment with the title "(.*?)" and the body "(.*?)"$/) do |title, body|
  click_on "Add new HTML attachment"
  fill_in "Title", with: title
  fill_in "Body", with: body
  check manually_numbered_headings
  click_on "Save"
end

When(/^I add an external attachment with the title "(.*?)" and the URL "(.*?)"$/) do |title, url|
  create_external_attachment(url, title)
end

When(/^I try and upload an attachment but there are validation errors$/) do
  ensure_path admin_publication_path(Publication.last)
  click_on "Modify attachments"
  click_on "Upload new file attachment"
  attach_file "File", Rails.root.join("test/fixtures/greenpaper.pdf")
  click_on "Save"
end

Then(/^I should be able to submit the attachment without re-uploading the file$/) do
  fill_in "Title", with: "Title that was missing before"
  click_on "Save"

  expect(2).to eq(Publication.last.attachments.count)
  expect("Title that was missing before").to eq(Publication.last.attachments.last.title)
end

Then(/^the .* "(.*?)" should have (\d+) attachments$/) do |title, expected_number_of_attachments|
  expect(expected_number_of_attachments.to_i).to eq(Edition.find_by(title:).attachments.count)
end

When(/^I set the order of attachments to:$/) do |attachment_order|
  attachment_order.hashes.each do |attachment_info|
    attachment = Attachment.find_by(title: attachment_info[:title])
    fill_in "ordering[#{attachment.id}]", with: attachment_info[:order]
  end
  click_on using_design_system? ? "Update order" : "Save attachment order"
end

Then(/^the attachments should be in the following order:$/) do |attachment_list|
  if using_design_system?
    attachment_names = all("table td:first").map(&:text)

    attachment_list.hashes.each_with_index do |attachment_info, index|
      attachment = Attachment.find_by(title: attachment_info[:title])
      expect(attachment.title).to eq(attachment_names[index])
    end
  else
    attachment_ids = all(".existing-attachments > li").map { |element| element[:id] }

    attachment_list.hashes.each_with_index do |attachment_info, index|
      attachment = Attachment.find_by(title: attachment_info[:title])
      expect("attachment_#{attachment.id}").to eq(attachment_ids[index])
    end
  end
end

Given(/^a draft closed consultation "(.*?)" with an outcome exists$/) do |title|
  create(:consultation_with_outcome, :draft, title:)
end

When(/^I go to the outcome for the consultation "(.*?)"$/) do |title|
  consultation = Consultation.find_by(title:)
  visit admin_consultation_outcome_path(consultation)
end

Then(/^the outcome for the consultation should have the attachment "(.*?)"$/) do |attachment_title|
  expect(page).to_not have_selector(".flash.alert")
  expect(page).to have_content(attachment_title)
end

Then(/^I can see the attachment title "([^"]*)"$/) do |text|
  expect(page).to have_selector("li.attachment", text:)
end

Then(/^I can see the preview link to the attachment "(.*?)"$/) do |attachment_title|
  expect(page).to have_link("a", href: /draft-origin/, text: attachment_title)
end

When(/^I upload an html attachment with the title "(.*?)" and the isbn "(.*?)"$/) do |title, isbn|
  click_on "Add new HTML attachment"
  fill_in "Title", with: title
  fill_in "ISBN", with: isbn
  fill_in "Body", with: "Body"
  check manually_numbered_headings
  click_on "Save"
end

When(/^I publish the draft edition for publication "(.*?)"$/) do |publication_title|
  publication = Publication.find_by title: publication_title
  publication.update!(state: "published", major_change_published_at: Time.zone.today)
end

Then(/^the html attachment "(.*?)" includes the isbn "(.*?)"$/) do |attachment_title, isbn|
  html_attachment = HtmlAttachment.find_by title: attachment_title

  expect(attachment_title).to eq(html_attachment.title)
  expect(isbn).to eq(html_attachment.isbn)
end

Then(/^I see a validation error for uploading attachments$/) do
  expect(page).to have_content("must have finished uploading")
end
