When(/^I visit the attachments page$/) do
  first(:link, 'Attachments').click
end

When(/^the (?:attachment|image)s? (?:has|have) been virus\-checked$/) do
  FileUtils.cp_r(Whitehall.incoming_uploads_root + '/.', Whitehall.clean_uploads_root + "/")
  FileUtils.rm_rf(Whitehall.incoming_uploads_root)
  FileUtils.mkdir(Whitehall.incoming_uploads_root)
end

When(/^I start editing the attachments from the .*? page$/) do
  click_on 'Modify attachments'
end

When(/^I upload a file attachment with the title "(.*?)" and the file "(.*?)"$/) do |title, fixture_file_name|
  click_on 'Upload new file attachment'
  fill_in 'Title', with: title
  attach_file 'File', Rails.root + "test/fixtures/#{fixture_file_name}"
  click_on 'Save'
end

When(/^I upload an html attachment with the title "(.*?)" and the body "(.*?)"$/) do |title, body|
  click_on 'Add new HTML attachment'
  fill_in 'Title', with: title
  fill_in 'Body', with: body
  check 'Manually numbered headings'
  click_on 'Save'
end

When(/^I add an external attachment with the title "(.*?)" and the URL "(.*?)"$/) do |title, url|
  create_external_attachment(url, title)
end

When(/^I try and upload an attachment but there are validation errors$/) do
  ensure_path admin_publication_path(Publication.last)
  click_on 'Modify attachments'
  click_on 'Upload new file attachment'
  attach_file 'File', Rails.root + "test/fixtures/greenpaper.pdf"
  click_on 'Save'
end

Then(/^I should be able to submit the attachment without re\-uploading the file$/) do
  fill_in 'Title', with: 'Title that was missing before'
  click_on 'Save'

  assert_equal 2, Publication.last.attachments.count
  assert_equal 'Title that was missing before', Publication.last.attachments.last.title
end

Then(/^the .* "(.*?)" should have (\d+) attachments$/) do |title, expected_number_of_attachments|
  assert_equal expected_number_of_attachments.to_i, Edition.find_by(title: title).attachments.count
end

When(/^I set the order of attachments to:$/) do |attachment_order|
  attachment_order.hashes.each do |attachment_info|
    attachment = Attachment.find_by(title: attachment_info[:title])
    fill_in "ordering[#{attachment.id}]", with: attachment_info[:order]
  end
  click_on 'Save attachment order'
end

Then(/^the attachments should be in the following order:$/) do |attachment_list|
  attachment_ids = page.all('.existing-attachments > li').map { |element| element[:id] }

  attachment_list.hashes.each_with_index do |attachment_info, index|
    attachment = Attachment.find_by(title: attachment_info[:title])

    assert_equal "attachment_#{attachment.id}", attachment_ids[index]
  end
end

Given(/^a draft closed consultation "(.*?)" with an outcome exists$/) do |title|
  create(:consultation_with_outcome, :draft, title: title)
end

When(/^I go to the outcome for the consultation "(.*?)"$/) do |title|
  consultation = Consultation.find_by(title: title)
  visit admin_consultation_outcome_path(consultation)
end

Then(/^the outcome for the consultation should have the attachment "(.*?)"$/) do |attachment_title|
  assert page.has_no_selector?(".flash.alert")
  assert page.has_content?(attachment_title)
end

Then(/^I can see the attachment title "([^"]*)"$/) do |text|
  assert page.has_css?('li.attachment', text: text)
end

Then(/^I can see the preview link to the attachment "(.*?)"$/) do |attachment_title|
  assert page.has_link?("a", href: /draft-origin/, text: attachment_title)
end

When(/^I upload an html attachment with the title "(.*?)" and the isbn "(.*?)" and the web isbn "(.*?)" and the contact address "(.*?)"$/) do |title, isbn, web_isbn, contact_address|
  click_on "Add new HTML attachment"
  fill_in "Title", with: title
  fill_in "Print ISBN", with: isbn
  fill_in "Web ISBN", with: web_isbn
  fill_in "Organisation's Contact Details", with: contact_address
  fill_in "Body", with: "Body"
  check "Manually numbered headings"
  click_on "Save"
end

When(/^I publish the draft edition for publication "(.*?)"$/) do |publication_title|
  publication = Publication.find_by title: publication_title
  publication.update!(state: 'published', major_change_published_at: Date.today)
end

Then(/^the html attachment "(.*?)" includes the contact address "(.*?)" and the isbn "(.*?)" and the web isbn "(.*?)"$/) do |attachment_title, contact_address, isbn, web_isbn|
  html_attachment = HtmlAttachment.find_by title: attachment_title

  assert_equal attachment_title, html_attachment.title
  assert_equal contact_address, html_attachment.print_meta_data_contact_address
  assert_equal isbn, html_attachment.isbn
  assert_equal web_isbn, html_attachment.web_isbn
end
