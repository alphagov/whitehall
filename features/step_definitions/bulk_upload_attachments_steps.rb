When /^I upload a zip file with a new attachment and a replacement attachment to the publication "([^"]*)"$/ do |title|
  pub = Publication.find_by_title(title)
  visit edit_admin_publication_path(pub)

  choose 'Bulk upload'
  within('#bulk_upload_attachments') do
    attach_file 'Zip file', new_attachments_zip_file
    click_on 'Bulk upload'
  end
end

When /^I upload a zip file of new attachments to my new document$/ do
  choose 'Bulk upload'
  within('#bulk_upload_attachments') do
    attach_file 'Zip file', new_attachments_zip_file
    click_on 'Bulk upload'
  end
end

When /^I complete my edits by filling in the metadata for the new attachment$/ do
  fill_in "edition[edition_attachments_attributes][1][attachment_attributes][title]", with: 'a-new-attachment-title'
  click_on 'Save'
end

When /^I complete my draft by filling in the metadata for the new attachments$/ do
  fill_in "edition[edition_attachments_attributes][0][attachment_attributes][title]", with: 'my-first-new-attachment-title'
  fill_in "edition[edition_attachments_attributes][1][attachment_attributes][title]", with: 'my-second-new-attachment-title'
  click_on 'Save'
end

Then /^I should see that I'm replacing the existing attachment, and adding a new one$/ do
  pub = Publication.last

  assert page.has_css?('.alert-info', text: 'check all the metadata is correct')

  existing_attachment = pub.attachments.first
  @bulk_upload_replaced_attachment_data = existing_attachment.attachment_data

  assert page.has_css?("input[name='edition[edition_attachments_attributes][0][attachment_attributes][id]'][value='#{existing_attachment.id}']")
  assert page.has_css?("input[name='edition[edition_attachments_attributes][0][attachment_attributes][attachment_action]'][value='replace']")
  assert page.has_css?("input[name='edition[edition_attachments_attributes][0][attachment_attributes][attachment_data_attributes][to_replace_id]'][value='#{existing_attachment.attachment_data.id}']")
  assert page.has_no_css?("input[name='edition[edition_attachments_attributes][0][attachment_attributes][attachment_data_attributes][id]']")
  assert page.has_css?("input[name='edition[edition_attachments_attributes][0][attachment_attributes][attachment_data_attributes][file]']")
  assert page.has_css?("input[name='edition[edition_attachments_attributes][0][attachment_attributes][attachment_data_attributes][file_cache]'][value*='greenpaper.pdf']")

  assert page.has_no_css?("input[name='edition[edition_attachments_attributes][1][attachment_attributes][id]']")
  assert page.has_no_css?("input[name='edition[edition_attachments_attributes][1][attachment_attributes][attachment_action]']")
  assert page.has_no_css?("input[name='edition[edition_attachments_attributes][1][attachment_attributes][attachment_data_attributes][to_replace_id]']")
  assert page.has_no_css?("input[name='edition[edition_attachments_attributes][1][attachment_attributes][attachment_data_attributes][id]']")
  assert page.has_css?("input[name='edition[edition_attachments_attributes][1][attachment_attributes][attachment_data_attributes][file]']")
  assert page.has_css?("input[name='edition[edition_attachments_attributes][1][attachment_attributes][attachment_data_attributes][file_cache]'][value*='two-pages.pdf']")
end

Then /^I should see that I'm adding two new attachments$/ do
  assert page.has_css?('.alert-info', text: 'check all the metadata is correct')

  assert page.has_no_css?("input[name='edition[edition_attachments_attributes][0][attachment_attributes][id]']")
  assert page.has_no_css?("input[name='edition[edition_attachments_attributes][1][attachment_attributes][attachment_action]']")
  assert page.has_no_css?("input[name='edition[edition_attachments_attributes][0][attachment_attributes][attachment_data_attributes][to_replace_id]']")
  assert page.has_no_css?("input[name='edition[edition_attachments_attributes][0][attachment_attributes][attachment_data_attributes][id]']")
  assert page.has_css?("input[name='edition[edition_attachments_attributes][0][attachment_attributes][attachment_data_attributes][file]']")
  assert page.has_css?("input[name='edition[edition_attachments_attributes][0][attachment_attributes][attachment_data_attributes][file_cache]'][value*='two-pages.pdf']")

  assert page.has_no_css?("input[name='edition[edition_attachments_attributes][1][attachment_attributes][id]']")
  assert page.has_no_css?("input[name='edition[edition_attachments_attributes][1][attachment_attributes][attachment_action]']")
  assert page.has_no_css?("input[name='edition[edition_attachments_attributes][1][attachment_attributes][attachment_data_attributes][to_replace_id]']")
  assert page.has_no_css?("input[name='edition[edition_attachments_attributes][1][attachment_attributes][attachment_data_attributes][id]']")
  assert page.has_css?("input[name='edition[edition_attachments_attributes][1][attachment_attributes][attachment_data_attributes][file]']")
  assert page.has_css?("input[name='edition[edition_attachments_attributes][1][attachment_attributes][attachment_data_attributes][file_cache]'][value*='greenpaper.pdf']")
end

Then /^I should not see a link to the replaced attachment$/ do
  assert page.has_no_css?(".attachment a[href*='#{@bulk_upload_replaced_attachment_data.url}']")
end

Then /^I should see a link to the (new|replacement) attachment$/ do |which_attachment|
  pub = Publication.last
  @bulk_upload_replaced_attachment_data.reload
  which_attachment =
    if which_attachment == 'new'
      pub.attachments.detect { |a| a.attachment_data_id != @bulk_upload_replaced_attachment_data.replaced_by_id }
    else
      pub.attachments.detect { |a| a.attachment_data_id == @bulk_upload_replaced_attachment_data.replaced_by_id }
    end

  assert page.has_css?(".attachment a[href*='#{which_attachment.attachment_data.url}']")
end

Then /^I should see links to the new attachments$/ do
  assert page.has_css?(".attachment a[href*='greenpaper.pdf']")
  assert page.has_css?(".attachment a[href*='two-pages.pdf']")
end

Then /^the replaced data file should redirect to the replacement data file$/ do
  assert_final_path(@bulk_upload_replaced_attachment_data.url, @bulk_upload_replaced_attachment_data.replaced_by.url)
end
