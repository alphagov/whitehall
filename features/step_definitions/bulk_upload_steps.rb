When("I bulk upload files and give them titles") do
  @edition = Edition.last
  visit admin_edition_attachments_path(@edition)

  page.attach_file [Rails.root.join("test/fixtures/greenpaper.pdf"), Rails.root.join("test/fixtures/two-pages.pdf")]

  click_button "Upload"
  fill_in "bulk_upload[attachments][0]_title", with: "Two pages title"
  fill_in "bulk_upload[attachments][1]_title", with: "Greenpaper title"
  click_button "Save"
end

Then(/^I should see that the news article has attachments$/) do
  expect(page).to have_current_path(admin_edition_attachments_path(@edition))

  expect(2).to eq(@edition.attachments.count)

  expect("Two pages title").to eq(@edition.attachments[0].title)
  expect("two-pages.pdf").to eq(@edition.attachments[0].filename)
  expect("Greenpaper title").to eq(@edition.attachments[1].title)
  expect("greenpaper.pdf").to eq(@edition.attachments[1].filename)
end

When(/^I bulk upload files including the file "(.*?)"$/) do |_file|
  @old_attachment_data = @attachment.attachment_data
  visit admin_edition_attachments_path(@edition)

  page.attach_file [Rails.root.join("test/fixtures/greenpaper.pdf"), Rails.root.join("test/fixtures/two-pages.pdf")]

  click_button "Upload"
  fill_in "bulk_upload[attachments][0]_title", with: "Two pages title"
  click_button "Save"
end

Then(/^the greenpaper\.pdf attachment file should be replaced with the new file$/) do
  expect(page).to have_current_path(admin_edition_attachments_path(@edition))

  expect(@attachment).to eq(@edition.reload.attachments[0])
  expect("greenpaper.pdf").to eq(@edition.attachments[0].filename)
  expect(@old_attachment_data).to_not eq(@edition.attachments[0].attachment_data)
  expect(@edition.attachments[0].attachment_data).to eq(@old_attachment_data.reload.replaced_by)
end

Then(/^any other files should be added as new attachments$/) do
  expect("Two pages title").to eq(@edition.attachments[1].title)
  expect("two-pages.pdf").to eq(@edition.attachments[1].filename)
end
