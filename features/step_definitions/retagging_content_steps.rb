# rubocop:disable Style/GlobalVars
Given("the documents and organisations I am retagging contain errors") do
  $csv_to_submit = <<~CSV
    Slug,New lead organisations,New supporting organisations,Document type
    /made-up-slug,government-digital-service,geospatial-commission,Publication
  CSV
end

When("I visit the retagging page") do
  visit admin_retagging_index_path
end

When("I submit my CSV of documents to be retagged") do
  fill_in "csv_input", with: $csv_to_submit
  click_button "Preview changes"
end

Then("I should be on the retagging page with my CSV input still present") do
  expect(current_url).to eq(admin_retagging_index_url)
  expect(find_field("csv_input").value.gsub("\r\n", "\n")).to eq($csv_to_submit)
end
# rubocop:enable Style/GlobalVars

Then("I should see a summary of retagging errors") do
  expect(page).to have_content("Errors with CSV input:")
  expect(page).to have_content("Document not found: made-up-slug")
  expect(page).to have_content("Organisation not found: government-digital-service")
end
