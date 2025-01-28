# rubocop:disable Style/GlobalVars
Given("the documents and organisations I am retagging exist") do
  $csv_to_submit = <<~CSV
    Slug,New lead organisations,New supporting organisations,Document type
    /government/publications/linked-identifier-schemes-best-practice-guide,"cabinet-office,government-digital-service",geospatial-commission,Publication
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

When("I visit the retagging page") do
  visit admin_retagging_index_path
end

When("I submit my CSV of documents to be retagged") do
  fill_in "csv_input", with: $csv_to_submit
  click_button "Preview changes"
end

Then("I can see a summary of the proposed changes") do
  expect(page).to have_content("Retag content - preview changes")
  table_row = find(".govuk-table__body .govuk-table__row:first")
  expect(table_row).to have_selector(".govuk-table__cell", text: "linked-identifier-schemes-best-practice-guide")
  expect(table_row).to have_selector(".govuk-table__cell", text: "Added cabinet-office, government-digital-service, Removed some-other-org. Result: cabinet-office, government-digital-service")
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

Then(/when I click "(.+)" on this retagging screen/) do |button_text|
  click_button button_text
end

Then("I am redirected to the retagging index page") do
  expect(current_url).to eq(admin_retagging_index_url)
end

Then("I see a confirmation message that my documents are being retagged") do
  expect(page.find(".govuk-notification-banner--success")).to have_text("Retagging in progress.")
end

And("the changes should have been actioned") do
  doc1 = Document.find_by(slug: "linked-identifier-schemes-best-practice-guide")
  doc2 = Document.find_by(slug: "search-engine-optimisation-for-publishers-best-practice-guide")

  expect(doc1.latest_edition.lead_organisations.map(&:slug)).to eq(%w[cabinet-office government-digital-service])
  expect(doc1.latest_edition.supporting_organisations.map(&:slug)).to eq(%w[geospatial-commission])
  expect(doc2.latest_edition.lead_organisations.map(&:slug)).to eq(%w[government-digital-service])
  # The `.sort` below is needed as otherwise the response is `geospatial-commission, cabinet-office`
  # despite the order specified in the CSV. It's an established rule of the Whitehall domain that we
  # don't care about the order of supporting organisations.
  expect(doc2.latest_edition.supporting_organisations.map(&:slug).sort).to eq(%w[cabinet-office geospatial-commission])
end
