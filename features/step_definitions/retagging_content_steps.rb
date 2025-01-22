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

Then("I should see a summary of retagging errors") do
  expect(page).to have_content("Errors with CSV input:")
  expect(page).to have_content("Document not found: made-up-slug")
  expect(page).to have_content("Organisation not found: government-digital-service")
end

Given("the documents and organisations I am retagging exist") do
  $csv_to_submit = <<~CSV
    Slug,New lead organisations,New supporting organisations,Document type
    /government/publications/linked-identifier-schemes-best-practice-guide,government-digital-service,geospatial-commission,Publication
    /government/publications/search-engine-optimisation-for-publishers-best-practice-guide,government-digital-service,"cabinet-office, geospatial-commission",Publication
  CSV

  create(:organisation, slug: "government-digital-service")
  create(:organisation, slug: "geospatial-commission")
  co_org = create(:organisation, slug: "cabinet-office")
  some_other_org = create(:organisation, slug: "some-other-org")

  doc1 = create(:document, slug: "linked-identifier-schemes-best-practice-guide")
  create(
    :publication,
    :published,
    document: doc1,
    lead_organisations: [some_other_org],
    supporting_organisations: [],
  )

  doc2 = create(:document, slug: "search-engine-optimisation-for-publishers-best-practice-guide")
  create(
    :publication,
    :published,
    document: doc2,
    lead_organisations: [co_org],
    supporting_organisations: [some_other_org],
  )
end

Then("I can see a summary of the proposed changes") do
  expect(page).to have_content("Retag content - preview changes")
  table_row = find(".govuk-table__body .govuk-table__row:first")
  expect(table_row).to have_selector(".govuk-table__cell", text: "linked-identifier-schemes-best-practice-guide")
  expect(table_row).to have_selector(".govuk-table__cell", text: "Added government-digital-service, Removed some-other-org. Result: government-digital-service")
  expect(table_row).to have_selector(".govuk-table__cell", text: "Added geospatial-commission. Result: geospatial-commission")
  table_row = find(".govuk-table__body .govuk-table__row:last")
  expect(table_row).to have_selector(".govuk-table__cell", text: "search-engine-optimisation-for-publishers-best-practice-guide")
  expect(table_row).to have_selector(".govuk-table__cell", text: "Added government-digital-service, Removed cabinet-office. Result: government-digital-service")
  expect(table_row).to have_selector(".govuk-table__cell", text: "Added cabinet-office, geospatial-commission, Removed some-other-org. Result: cabinet-office, geospatial-commission")
end

And("my CSV input should be in a hidden field ready to confirm retagging") do
  expect(find("[name=csv_input]", visible: false).value.gsub("\r\n", "\n")).to eq($csv_to_submit)
end
# rubocop:enable Style/GlobalVars
