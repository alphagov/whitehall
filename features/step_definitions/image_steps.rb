Given("a draft document with images exists") do
  images = [build(:image), build(:image)]
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
  visit admin_edition_images_path(Edition.find_by(title:))
end

Then(/^I should see a list with (\d+) image/) do |count|
  expect(page).to have_selector(".app-view-edition-resource__preview", count:)
end

When(/^I select an image for the (?:detailed guide|publication)$/) do
  within ".images" do
    attach_file "File", jpg_image
    # Click event necessary for fieldset cloning - attaching file doesn't seem
    # to trigger the click event
    execute_script("document.querySelector('.js-upload-image-input').dispatchEvent(new CustomEvent('click', { bubbles: true }))")
    fill_in "Alt text", with: "minister of funk", match: :first
  end
end

When("I click to delete an image") do
  first("a", text: "Delete image").click
end

When("I click to edit the details of an image") do
  first("a", text: "Edit details").click
end

When("I click to hide the lead image") do
  find("button", text: "Remove lead image").click
end

When("I confirm the deletion") do
  find("button", text: "Delete image").click
end

When("I update the image details and save") do
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

And(/^I upload a (\d+)x(\d+) image$/) do |width, height|
  within "input.gem-c-file-upload" do
    if width == 960 && height == 640
      attach_file jpg_image
    elsif width == 64 && height == 96
      attach_file Rails.root.join("test/fixtures/horrible-image.64x96.jpg")
    elsif width == 960 && height == 960
      attach_file Rails.root.join("test/fixtures/images/960x960_jpeg.jpg")
    end
  end
  click_on "Upload"
end

Then(/^I am redirected to a page for image cropping$/) do
  expect(page).to have_content("Crop image")
end

And(/^I click the "Save and continue" button on the crop page$/) do
  click_on "Save and continue"
end

And(/^I click upload without attaching a file$/) do
  click_on "Upload"
end

Then(/^I should get the error message "(.*?)"$/) do |error_message|
  expect(page).to have_content(error_message)
end

Then(/^I should get (\d+) error message$/) do |count|
  expect(page).to have_selector(".gem-c-error-summary__list-item", count:)
end

Given(/^a draft case study with images with the alt text "([^"]*)" and "([^"]*)" exists$/) do |first_alt_text, second_alt_text|
  # Unfortunately, we have to use alt text here to distinguish between the images. The assets
  # are overwritten and stubbed out in asset_manager_helper.rb so the filename and url are always the same.
  images = [build(:image, alt_text: first_alt_text), build(:image, alt_text: second_alt_text)]
  @edition = create(:draft_case_study, images:)
end

And(/^I make the image with alt text "([^"]*)" the lead image$/) do |alt_text|
  image_container = find(".govuk-body", text: alt_text).ancestor("li")

  within image_container do
    click_button "Select as lead image"
  end
end

Then(/^I can see that the image with alt text "([^"]*)" is the lead image$/) do |alt_text|
  within ".app-c-edition-images-lead-image-component__lead_image" do
    expect(page).to have_content alt_text
  end
end

Then(/^I should see the organisations default news image$/) do
  within ".app-c-edition-images-lead-image-component__default_lead_image" do
    assert_selector "img", count: 1
  end
end
