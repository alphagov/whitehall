Then /^I should see a placeholder thumbnail whilst the attachment is being virus checked$/ do
  assert page.has_css?(".attachment a[href*='#{@attachment_filename}']", text: @attachment_title)

  within('#details') do
    assert_final_path(attachment_thumbnail_path, "thumbnail-placeholder.png")
  end
end

Then /^clicking on the attachment redirects me to an explanatory page$/ do
  within('#details') do
    page.find_link(@attachment_title).click
  end
  assert_match /placeholder/, page.current_path
end

When /^the (?:attachment|image)s? (?:has|have) been virus\-checked$/ do
  FileUtils.cp_r(Whitehall.incoming_uploads_root + '/.', Whitehall.clean_uploads_root + "/")
end

Then /^I can see the attachment thumbnail and download it$/ do
  within('#details') do
    assert_final_path(attachment_thumbnail_path, attachment_thumbnail_path)
    assert_final_path(attachment_path, attachment_path)
  end
end

Then /^the image will be quarantined for virus checking$/ do
  assert_final_path(person_image_path, "thumbnail-placeholder.png")
end

Then /^the virus checked image will be available for viewing$/ do
  assert_final_path(person_image_path, person_image_path)
end
