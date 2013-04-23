Then /^I should see a placeholder thumbnail whilst the attachment is being virus checked$/ do
  assert page.has_css?(".attachment a[href*='#{@attachment_filename}']", text: @attachment_title)

  assert_final_path(attachment_thumbnail_path, "thumbnail-placeholder.png")
end

Then /^clicking on the attachment redirects me to an explanatory page$/ do
  page.find('.attachment a').click
  page.current_path.should match(/placeholder/)
end

When /^the (?:attachment|image)s? (?:has|have) been virus\-checked$/ do
  incoming_path = CarrierWave::Uploader::Base.incoming_root
  clean_path = Whitehall.clean_upload_path
  FileUtils.cp_r(incoming_path.to_s + '/.', clean_path.to_s + "/")
end

Then /^I can see the attachment thumbnail and download it$/ do
  assert_final_path(attachment_thumbnail_path, attachment_thumbnail_path)
  assert_final_path(attachment_path, attachment_path)
end

Then /^the image will be quarantined for virus checking$/ do
  assert_final_path(person_image_path, "thumbnail-placeholder.png")
end

Then /^the virus checked image will be available for viewing$/ do
  assert_final_path(person_image_path, person_image_path)
end
