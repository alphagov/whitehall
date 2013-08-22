When(/^I upload a zip file containing several attachments and give them titles$/) do
  @edition = Edition.last
  visit admin_edition_attachments_path(@edition)
  click_link 'Bulk upload from Zip file'
  attach_file 'Zip file', Rails.root.join('test/fixtures/two-pages-and-greenpaper.zip')
  click_button 'Upload zip'

  fill_in 'bulk_upload_attachments_attributes_0_title', with: 'Two pages title'
  fill_in 'bulk_upload_attachments_attributes_1_title', with: 'Greenpaper title'
  click_button 'Save'
end

Then(/^I should see that the news article has attachments$/) do
  assert_current_url admin_edition_attachments_path(@edition)

  assert_equal 2, @edition.attachments.count

  assert_equal 'Two pages title', @edition.attachments[0].title
  assert_equal 'two-pages.pdf', @edition.attachments[0].filename
  assert_equal 'Greenpaper title', @edition.attachments[1].title
  assert_equal 'greenpaper.pdf', @edition.attachments[1].filename
end

When(/^I upload a zip file that contains a file "(.*?)"$/) do |arg1|
  @old_attachment_data = @attachment.attachment_data
  visit admin_edition_attachments_path(@edition)
  click_link 'Bulk upload from Zip file'
  attach_file 'Zip file', Rails.root.join('test/fixtures/two-pages-and-greenpaper.zip')
  click_button 'Upload zip'
  fill_in 'bulk_upload_attachments_attributes_0_title', with: 'Two pages title'
  click_button 'Save'
end

Then(/^the greenpaper\.pdf attachment file should be replaced with the new file$/) do
  assert_current_url admin_edition_attachments_path(@edition)
  assert_equal @attachment, @edition.reload.attachments[0]
  assert_equal 'greenpaper.pdf', @edition.attachments[0].filename
  refute_equal @old_attachment_data, @edition.attachments[0].attachment_data
  assert_equal @edition.attachments[0].attachment_data, @old_attachment_data.reload.replaced_by
end

Then(/^any other files should be added as new attachments$/) do
  assert_equal 'Two pages title', @edition.attachments[1].title
  assert_equal 'two-pages.pdf', @edition.attachments[1].filename
end
