def upload_file(width = nil, height = nil, image_usage_key = "govspeak_embed", file_override_960_640 = nil)
  file = if width == 960 && height == 640
           file_override_960_640 || jpg_image
         elsif width == 64 && height == 96
           Rails.root.join("test/fixtures/horrible-image.64x96.jpg")
         elsif width.present? && height.present?
           Rails.root.join("test/fixtures/images/#{width}x#{height}_jpeg.jpg")
         else
           Rails.root.join("test/fixtures/images/test-svg.svg")
         end

  if running_javascript?
    attach_file file do
      find(:label, "Upload images").click
    end
  else
    within "##{image_usage_key}_image_upload_form input.gem-c-file-upload" do
      attach_file file
    end
  end

  if width.present? && height.present?
    io_object = fixture_file_upload(file, "image/jpeg").tempfile.to_io
    stub_request(:get, %r{.*/media/.*/.*jpg}).to_return(status: 200, body: io_object, headers: {})
  else
    io_object = fixture_file_upload(file, "image/svg+xml").tempfile.to_io
    stub_request(:get, %r{.*/media/.*/.*svg}).to_return(status: 200, body: io_object, headers: {})
  end

  within "##{image_usage_key}_image_upload_form" do
    click_on "Upload"
  end
end

Given("a draft document with images exists") do
  svg_image_data = build(:image_data, file: File.open(Rails.root.join("test/fixtures/images/test-svg.svg")))
  image = build(:image, image_data: svg_image_data)
  images = [build(:image), image]

  @edition = create(:draft_publication, body: "!!2", images:)
end

Given("a draft case study with images exists") do
  images = [build(:image), build(:image)]
  @edition = create(:draft_case_study, body: "!!2", images:, lead_image: images.first)
end

Given("an organisation with a default news image exists") do
  default_news_image = build(:featured_image_data)
  @organisation = create(:organisation, default_news_image:)
end

And("the organisation has a draft case study with images") do
  images = [build(:image), build(:image)]
  @edition = create(:draft_case_study, images:, lead_organisations: [@organisation])
end

When("I visit the images tab of the document with images") do
  visit admin_edition_images_path(@edition)
end

When(/^I visit the images tab of the document "([^"]*)"$/) do |title|
  @edition ||= Edition.find_by(title:)
  visit admin_edition_images_path(Edition.find_by(title:))
end

Then(/^I should see a list with (\d+) image/) do |count|
  expect(page).to have_selector("ul .app-view-edition-resource__preview", count:)
end

Then(/^I should see a list with (\d+) (.*) image/) do |_count, image_usage_key|
  expect(page).not_to have_selector("##{image_usage_key}_image_upload_form")
end

Then(/^I should not see the form for uploading a (.*) image/) do |image_usage_key|
  expect(page).not_to have_selector("##{image_usage_key}_image_upload_form")
end

Then(/^I should see that the image requires cropping/) do
  expect(page).to have_content("Requires crop")
end

Then(/^I should not see that the image requires cropping/) do
  expect(page).not_to have_content("Requires crop")
end

When(/^I select an image for the (?:detailed guide|publication)$/) do
  within ".images" do
    attach_file "File", jpg_image
    # Click event necessary for fieldset cloning - attaching file doesn't seem
    # to trigger the click event
    execute_script("document.querySelector('.js-upload-image-input').dispatchEvent(new CustomEvent('click', { bubbles: true }))")
  end
end

When("I click to delete an image") do
  first("a", text: "Delete image").click
end

When("I click to edit the details of an image") do
  io_object = fixture_file_upload(jpg_image, "image/jpeg").tempfile.to_io

  stub_request(:get, %r{.*/media/.*/*.jpg}).to_return(status: 200, body: io_object, headers: {})
  first("a", text: "Edit details").click
end

When("I click to edit the details of the image that needs to be cropped") do
  io_object = fixture_file_upload(Rails.root.join("test/fixtures/images/960x960_jpeg.jpg"), "image/jpeg").tempfile.to_io

  stub_request(:get, %r{.*/media/.*/960x960_jpeg.jpg}).to_return(status: 200, body: io_object, headers: {})
  find_all("a", text: "Edit details").last.click
end

Then("I should see the image cropper in the following edit screen") do
  expect(page).to have_selector(".app-c-image-cropper")
end

Then("I should not see the image cropper in the following edit screen") do
  expect(page).not_to have_selector(".app-c-image-cropper")
end

When("I click to hide the lead image") do
  find("button", text: "Remove lead image").click
end

Then("I should see the default lead image") do
  expect(page).to have_content("Default lead image")
end

When("I visit the images tab of the standard edition with images") do
  @edition = StandardEdition.first
  visit admin_edition_images_path(@edition)
end

When("I confirm the deletion") do
  find("button", text: "Delete image").click
end

When("I update the image details and save") do
  io_object = fixture_file_upload(Rails.root.join("test/fixtures/images/960x960_jpeg.jpg"), "image/png").tempfile.to_io

  stub_request(:get, %r{.*/media/.*/960x960_jpeg.jpg}).to_return(status: 200, body: io_object, headers: {})

  fill_in "image[caption]", with: "Test caption"
  find("button", text: "Save").click
end

Then "I should see a successfully deleted banner" do
  expect(page).to have_content("has been deleted")
end

Then "I should see a updated banner" do
  expect(page).to have_content("details updated")
end

Then "I should see the updated image details" do
  expect(page).to have_content("Test caption")
end

Then "I should see a button to select a custom lead image" do
  assert_selector ".govuk-button", text: "Select as lead image", count: 2
end

And "I should see a button to choose to use the default image" do
  assert_selector ".govuk-button", text: "Use default image", count: 1
end

And(/^I upload an image$/) do
  upload_file
end

And(/^I upload a (\d+)x(\d+) image$/) do |width, height|
  upload_file(width, height)
end

And(/^I upload a (\d+)x(\d+) (.*) image$/) do |width, height, image_usage_key|
  upload_file(width, height, image_usage_key)
end

And(/^I upload multiple images including a (\d+)x(\d+) image$/) do |width, height|
  file = if width == 960 && height == 640
           jpg_image
         elsif width == 64 && height == 96
           Rails.root.join("test/fixtures/horrible-image.64x96.jpg")
         elsif width == 960 && height == 960
           Rails.root.join("test/fixtures/images/960x960_jpeg.jpg")
         end

  files = [Rails.root.join("test/fixtures/big-cheese.960x640.jpg"), file]

  if running_javascript?
    attach_file files do
      find(:label, "Upload images").click
    end
  else
    within "#govspeak_embed_image_upload_form input.gem-c-file-upload" do
      attach_file files
    end
  end

  within "#govspeak_embed_image_upload_form" do
    click_on "Upload"
  end
end

And(/^I click upload without attaching a file$/) do
  within "#govspeak_embed_image_upload_form" do
    click_on "Upload"
  end
end

Then(/^I should get the error message "(.*?)"$/) do |error_message|
  expect(page).to have_content(error_message)
end

Then(/^I should get (\d+) error message$/) do |count|
  expect(page).to have_selector(".gem-c-error-summary__list-item", count:)
end

Given(/^a draft case study with images with the captions "([^"]*)" and "([^"]*)" exists$/) do |first_caption, second_caption|
  images = [build(:image, caption: first_caption), build(:image, caption: second_caption)]
  @edition = create(:draft_case_study, images:)
end

And(/^I make the image with caption "([^"]*)" the lead image$/) do |caption|
  image_container = find(".govuk-body", text: caption).ancestor("li")

  within image_container do
    click_button "Select as lead image"
  end
end

Then(/^I can see that the image with caption "([^"]*)" is the lead image$/) do |caption|
  within ".app-c-edition-images-lead-image-component__lead_image" do
    expect(page).to have_content caption
  end
end

Then(/^I should see the organisations default news image$/) do
  within ".app-c-edition-images-lead-image-component__default_lead_image" do
    assert_selector "img", count: 1
  end
end

Then(/^I should see a card associated with the (.*) image usage$/) do |image_usage_key|
  expect(page).to have_selector(".govuk-summary-card__title", text: image_usage_key.titleize)
  expect(page).to have_selector("a[href=\"/government/admin/editions/#{@edition.id}/images/new?usage=#{image_usage_key}\"]")
end

Then(/^I click to add (?:a|an) (.*) image$/) do |image_usage_key|
  within "#uploaded_#{image_usage_key}_image_card" do
    click_on "Add"
  end
end

Then(/^I should see the (.*) image is uploaded$/) do |image_usage_key|
  within "#uploaded_#{image_usage_key}_image_card" do
    assert_selector ".app-view-edition-resource__preview", count: 1
  end
end
