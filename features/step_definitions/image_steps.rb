When(/^I select an image for the (?:detailed guide|publication)$/) do
  within ".images" do
    attach_file "File", jpg_image
    # Click event necessary for fieldset cloning - attaching file doesn't seem
    # to trigger the click event
    execute_script("document.querySelector('.js-upload-image-input').dispatchEvent(new CustomEvent('click', { bubbles: true }))")
    fill_in "Alt text", with: "minister of funk", match: :first
  end
end
