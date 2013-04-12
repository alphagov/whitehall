When /^I select an image for the (?:detailed guide|publication)$/ do
  within ".images" do
    attach_file "File", jpg_image
    fill_in "Alt text", with: "minister of funk"
  end
end

