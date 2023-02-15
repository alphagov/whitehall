Given("a draft document with images exists") do
  images = [build(:image), build(:image)]
  @edition = create(:draft_publication, body: "!!2", images:)
end

When("I visit the images tab of the the document with images") do
  visit admin_edition_images_path(@edition)
end

Then("I should see a list of the images") do
  expect(page).to have_selector(".app-view-edition-images__details", count: 2)
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
