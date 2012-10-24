Then /^I should see a placeholder thumbnail whilst the attachment is being virus checked$/ do
  assert page.has_css?(".attachment a[href*='#{@attachment_filename}']", text: @attachment_title)

  assert_final_path(attachment_thumbnail_path, "thumbnail-virus-checking.jpg")
end

Then /^clicking on the attachment redirects me to an explanatory page$/ do
  page.find('.attachment a').click
  page.current_path.should match(/placeholder/)
end

When /^the (?:attachment|image) has been virus\-checked$/ do
  incoming_root = CarrierWave::Uploader::Base.incoming_root
  clean_root = CarrierWave::Uploader::Base.clean_root
  FileUtils.cp_r(incoming_root.to_s, clean_root.to_s + "/")
end

Then /^I can see the attachment thumbnail and download it$/ do
  assert_final_path(attachment_thumbnail_path, attachment_thumbnail_path)
  assert_final_path(attachment_path, attachment_path)
end

When /^I check the image for the new person$/ do
  page.find(".person .name a").click
end

Then /^the image will be quarantined for virus checking$/ do
  assert_final_path(person_image_path, "thumbnail-virus-checking.jpg")
end

Then /^the virus checked image will be available for viewing$/ do
  assert_final_path(person_image_path, person_image_path)
end
