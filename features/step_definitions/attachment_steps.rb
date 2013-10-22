When(/^I make unsaved changes to the news article$/) do
  @news_article = NewsArticle.last
  visit edit_admin_news_article_path(@news_article)
  fill_in 'Title', with: 'An unsaved change'
end

When(/^I attempt to visit the attachments page$/) do
  click_on 'Attachments'
end

Then(/^I should stay on the edit screen for the news article$/) do
  assert_equal edit_admin_news_article_path(@news_article), page.current_path
end

When(/^I save my changes$/) do
  click_on 'Save and continue editing'
end

Then(/^I can visit the attachments page$/) do
  click_on 'Attachments'
  assert_equal admin_edition_attachments_path(@news_article), page.current_path
end

When /^the (?:attachment|image)s? (?:has|have) been virus\-checked$/ do
  FileUtils.cp_r(Whitehall.incoming_uploads_root + '/.', Whitehall.clean_uploads_root + "/")
  FileUtils.rm_rf(Whitehall.incoming_uploads_root)
  FileUtils.mkdir(Whitehall.incoming_uploads_root)
end

Then /^the image will be quarantined for virus checking$/ do
  assert_final_path(person_image_path, "thumbnail-placeholder.png")
end

Then /^the virus checked image will be available for viewing$/ do
  assert_final_path(person_image_path, person_image_path)
end

When(/^I start editing the attachments from the .*? page$/) do
  click_on 'Edit attachments'
end

When(/^I upload a file attachment with the title "(.*?)" and the file "(.*?)"$/) do |title, fixture_file_name|
  click_on 'Upload new file attachment'
  fill_in 'Title', with: title
  attach_file 'File', Rails.root+"test/fixtures/#{fixture_file_name}"
  click_on 'Save'
end

When(/^I upload an html attachment with the title "(.*?)" and the body "(.*?)"$/) do |title, body|
  click_on 'Add new HTML attachment'
  fill_in 'Title', with: title
  fill_in 'Body', with: body
  click_on 'Save'
end

Then(/^the publication "(.*?)" should have (\d+) attachments$/) do |publication_title, expected_number_of_attachments|
  assert_equal expected_number_of_attachments.to_i, Publication.find_by_title(publication_title).attachments.count
end

When(/^I set the order of attachments to:$/) do |attachment_order|
  attachment_order.hashes.each do |attachment_info|
    attachment = Attachment.find_by_title(attachment_info[:title])
    fill_in "ordering[#{attachment.id}]", with: attachment_info[:order]
  end
  click_on 'Save attachment order'
end

Then(/^the attachments should be in the following order:$/) do |attachment_list|
  attachment_list.hashes.each_with_index do |attachment_info, index|
    attachment = Attachment.find_by_title(attachment_info[:title])
    page.assert_selector(".existing-attachments li#attachment_#{attachment.id}:nth-child(#{index+1})")
  end
end
