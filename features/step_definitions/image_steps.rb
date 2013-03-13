When /^I select an image for the (?:detailed guide|publication)$/ do
  within ".images" do
    attach_file "File", Rails.root.join("test/fixtures/minister-of-funk.960x640.jpg")
    fill_in "Alt text", with: "minister of funk"
  end
end

