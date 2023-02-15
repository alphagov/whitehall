Given("a draft document with images exists") do
  images = [build(:image), build(:image)]
  @edition = create(:draft_publication, body: "!!2", images:)
end

When("I visit the images tab of the document with images") do
  visit admin_edition_images_path(@edition)
end

Then(/^I should see a list with (\d+) image/) do |count|
  expect(page).to have_selector(".app-view-edition-images__details", count:)
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

Then(/^the page should not have an images tab$/) do
  expect(page).to_not have_link("li.app-c-secondary-navigation__list-item a", text: "Images")
end

Then(/^I can navigate to the images tab$/) do
  find("li.app-c-secondary-navigation__list-item a", text: "Images").click
  expect(page).to have_content("Upload an image")
end

When("I click to delete an image") do
  first("a", text: "Delete image").click
end

When("I click to edit the details of an image") do
  first("a", text: "Edit details").click
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
