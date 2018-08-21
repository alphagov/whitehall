When(/^I select an image for the (?:detailed guide|publication)$/) do
  within ".images" do
    attach_file "File", jpg_image
    find(".js-upload-image-input").click # Click event necessary for fieldset cloning.
    fill_in "Alt text", with: "minister of funk", match: :first
  end
end
