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

When(/^I bulk upload files one with the same filename as an existing file$/) do
  visit admin_edition_attachments_path(@edition)

  @existing_attachment = @edition.attachments.first
  @existing_filename = @edition.attachments.first.filename
  @new_filename = "two-pages.pdf"

  page.attach_file [Rails.root.join("test/fixtures/#{@existing_filename}"), Rails.root.join("test/fixtures/#{@new_filename}")]

  click_button "Upload"
end

When(/^I only upload existing files$/) do
  visit admin_edition_attachments_path(@edition)

  @existing_titles = @edition.attachments.map(&:title)

  page.attach_file(@edition.attachments.map { |attachment| Rails.root.join("test/fixtures/#{attachment.filename}") })

  click_button "Upload"
end

When("I reject all the existing files") do
  @edition.attachments

  choose("bulk_upload[attachments][0]_attachment_data_keep_or_replace_reject")
  choose("bulk_upload[attachments][1]_attachment_data_keep_or_replace_reject")
end

When("I change the title and select replace for the existing file") do
  choose("Replace the existing file")
  fill_in "bulk_upload[attachments][1]_title", with: "Replacement Title"
end

When("I change the title and select reject for the existing file") do
  choose("Do not upload this file")
  fill_in "bulk_upload[attachments][1]_title", with: "Replacement Title"
end

When("I select keep file for existing file") do
  @new_kept_filename = "#{@existing_attachment.attachment_data.filename_without_extension}_1.#{@existing_attachment.attachment_data.file_extension}"
  choose("Keep both files")
end

When("I enter the same name as the existing file") do
  fill_in "Name for new file", with: @existing_filename
end

When("I do not enter a new file name") do
  fill_in "Name for new file", with: ""
end

When("I save the files") do
  fill_in "bulk_upload[attachments][0]_title", with: "Title"
  click_button "Save"
end

When("I save the files without entering a title for the new attachment") do
  click_button "Save"
end

And("I should see the new file name for the existing file") do
  expect(page).to have_content("File: #{@new_kept_filename}")
end

And("I should see the current file name for the existing file") do
  expect(page).to have_content("File: #{@existing_filename}")
end

And("I should not see an option to change Keep or Replace") do
  expect(page).not_to have_content("Matching attachment filename")
end

Then(/^I should see an error of "(.*)" on the bulk upload page$/) do |error|
  expect(page).not_to have_current_path(admin_edition_attachments_path(@edition))
  expect(@edition.reload.attachments.count).to eq 1

  expect(page).to have_selector(".gem-c-error-summary__list-item")
  expect(page).to have_content(error.to_s)
end

Then(/^I should see a notice of "(.*)" on the edition attachments index page$/) do |notice|
  expect(page).to have_current_path(admin_edition_attachments_path(@edition))
  expect(page).to have_content(notice)
end

Then(/^I should see that the news article has the new attachment and the existing attachment$/) do
  expect(page).to have_current_path(admin_edition_attachments_path(@edition))
  expect(@edition.reload.attachments.count).to eq 3
  expect(@edition.attachments.first.filename).to eq(@existing_filename)
  expect(@edition.attachments.second.filename).to eq(@new_filename)
  expect(@edition.attachments.last.filename).to eq(@new_kept_filename)
end

Then(/^I should see that the news article has the existing attachment with updated title and the new attachment$/) do
  expect(page).to have_current_path(admin_edition_attachments_path(@edition))
  expect(@edition.reload.attachments.count).to eq 2
  expect(@edition.attachments.first.filename).to eq(@existing_filename)
  expect(@edition.attachments.first.title).to eq("Replacement Title")
  expect(@edition.attachments.second.filename).to eq(@new_filename)
end

Then(/^I should see that the news article has the existing attachment with original title and the new attachment$/) do
  expect(page).to have_current_path(admin_edition_attachments_path(@edition))
  expect(@edition.reload.attachments.count).to eq 2
  expect(@edition.attachments.first.filename).to eq(@existing_filename)
  expect(@edition.attachments.first.title).not_to eq("Replacement Title")
  expect(@edition.attachments.second.filename).to eq(@new_filename)
end

Then(/^I should see that the news article has the existing attachments with original titles$/) do
  expect(page).to have_current_path(admin_edition_attachments_path(@edition))
  expect(@edition.reload.attachments.count).to eq 2
  @edition.attachments.each_with_index do |attachment, index|
    expect(attachment.title).to eq @existing_titles[index]
  end
end
