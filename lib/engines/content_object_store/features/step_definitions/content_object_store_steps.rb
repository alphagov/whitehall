require_relative "../support/stubs"

Given(/^the content object store feature flag is (enabled|disabled)$/) do |enabled|
  @test_strategy ||= Flipflop::FeatureSet.current.test!
  @test_strategy.switch!(:content_object_store, enabled == "enabled")
end

Given("a schema {string} exists with the following fields:") do |block_type, table|
  fields = table.hashes
  @schemas ||= {}
  body = {
    "type" => "object",
    "required" => fields.select { |f| f["required"] == "true" }.map { |f| f["field"] },
    "additionalProperties" => false,
    "properties" => fields.map { |f|
      [f["field"], { "type" => f["type"], "format" => f["format"] }]
    }.to_h,
  }
  @schemas[block_type] = build(:content_block_schema, block_type:, body:)
  ContentObjectStore::ContentBlock::Schema.stubs(:all).returns(@schemas.values)
end

When("I access the create object page") do
  visit content_object_store.new_content_object_store_content_block_edition_path
end

When("I click to create an object") do
  click_link "Create new object"
end

Then("I should see all the schemas listed") do
  @schemas.values.each do |schema|
    expect(page).to have_content(schema.name)
  end
end

When("I click on the {string} schema") do |schema_id|
  @schema = @schemas[schema_id]
  ContentObjectStore::ContentBlock::Schema.expects(:find_by_block_type).with(schema_id).at_least_once.returns(@schema)
  click_link @schema.name
end

Then("I should see a form for the schema") do
  expect(page).to have_content(@schema.name)
end

Then("I should see a back link to the document list page") do
  expect(page).to have_link("Back", href: content_object_store.content_object_store_content_block_documents_path)
end

Then("I should see a back link to the select schema page") do
  expect(page).to have_link("Back", href: content_object_store.new_content_object_store_content_block_edition_path)
end

Then("I should see a back link to the document page") do
  expect(page).to have_link(
    "Back",
    href: content_object_store.content_object_store_content_block_document_path(@content_block.document),
  )
end

Then("I should see a back link to the show page") do
  match_data = URI.parse(page.current_url).path.match(%r{content-block-editions/(\d+)/edit$})
  id = match_data[1] unless match_data.nil?
  expect(id).not_to be_nil, "Could not find an existing content block edition ID in the URL"
  expect(page).to have_link("Back", href: content_object_store.content_object_store_content_block_edition_path(id))
end

When("I complete the form with the following fields:") do |table|
  fields = table.hashes.first
  @title = fields.delete("title")
  @organisation = fields.delete("organisation")
  @details = fields

  fill_in "Title", with: @title

  select @organisation, from: "Lead organisation"

  fields.keys.each do |k|
    fill_in "content_object_store/content_block_edition_details_#{k}", with: @details[k]
  end

  click_on "Save and publish"
end

When("I complete the form") do
  @title = "My title"
  @details = @schema.fields.index_with { |f| "#{f} content" }

  fill_in "Title", with: @title
  @details.keys.each do |k|
    fill_in "content_object_store/content_block_edition_details_#{k}", with: @details[k]
  end
  click_on "Save and publish"
end

Then("the edition should have been created successfully") do
  assert_text "#{@schema.name} created successfully"

  edition = ContentObjectStore::ContentBlock::Edition.all.last

  assert_not_nil edition
  assert_not_nil edition.document

  assert_equal edition.title, @title
  @details.keys.each do |k|
    assert_equal edition.details[k], @details[k]
  end
end

Then("I should be taken back to the document page") do
  expect(page.current_url).to match(content_object_store.content_object_store_content_block_document_path(
                                      ContentObjectStore::ContentBlock::Edition.last.document,
                                    ))
end

Given("an email address content block has been created") do
  @content_blocks ||= []
  @email_address = "foo@example.com"
  @content_block = create(
    :content_block_edition,
    :email_address,
    details: { email_address: @email_address },
    creator: @user,
  )
  @content_blocks.push(@content_block)
end

When("I visit the page for the content block") do
  visit content_object_store.content_object_store_content_block_edition_path(@content_block)
end

When("I visit the document object store") do
  visit content_object_store.content_object_store_content_block_documents_path
end

Then("I should see the details for all documents") do
  assert_text "All content blocks"

  ContentObjectStore::ContentBlock::Document.find_each do |document|
    should_show_summary_card_for_email_address_content_block(
      document.title,
      document.latest_edition.details[:email_address],
    )
  end
end

When("I click to view the document") do
  @schema = @schemas[@content_block.document.block_type]
  click_link href: content_object_store.content_object_store_content_block_document_path(@content_block.document)
end

When("I click to view the edition") do
  @schema = @schemas[@content_block.document.block_type]
  click_link href: content_object_store.content_object_store_content_block_edition_path(@content_block)
end

Then("I should see the details for the email address content block") do
  assert_text "Manage an Email address"

  should_show_summary_list_for_email_address_content_block(
    @content_block.document.title,
    @email_address,
  )
end

When("I click the first change link") do
  first_link = find("a[href='#{content_object_store.edit_content_object_store_content_block_edition_path(@content_block)}']", match: :first)
  first_link.click
end

Then("I should see the edit form") do
  should_show_edit_form_for_email_address_content_block(
    @content_block.document.title,
    @email_address,
  )
end

When("I fill out the form") do
  fill_in "Title", with: "Changed title"
  fill_in "Email address", with: "changed@example.com"
  select "Ministry of Example", from: "Lead organisation"
  click_on "Save and publish"
end

When("I set all fields to blank") do
  fill_in "Title", with: ""
  fill_in "Email address", with: ""
  first("#lead_organisation option").select_option
  click_on "Save and publish"
end

Then("the edition should have been updated successfully") do
  should_show_summary_list_for_email_address_content_block("Changed title", "changed@example.com")
end

def should_show_summary_card_for_email_address_content_block(document_title, email_address)
  expect(page).to have_selector(".govuk-summary-list__key", text: "Title")
  expect(page).to have_selector(".govuk-summary-list__value", text: document_title)
  expect(page).to have_selector(".govuk-summary-list__key", text: "Email address")
  expect(page).to have_selector(".govuk-summary-list__value", text: email_address)
end

def should_show_summary_list_for_email_address_content_block(document_title, email_address)
  expect(page).to have_selector(".govuk-summary-list__key", text: "Title")
  expect(page).to have_selector(".govuk-summary-list__value", text: document_title)
  expect(page).to have_selector(".govuk-summary-list__actions", text: "Change")
  expect(page).to have_selector(".govuk-summary-list__key", text: "Email address")
  expect(page).to have_selector(".govuk-summary-list__value", text: email_address)
  expect(page).to have_selector(".govuk-summary-list__key", text: "Creator")
  expect(page).to have_selector(".govuk-summary-list__value", text: @user.name)
  expect(page).to have_selector(".govuk-summary-list__actions", text: "Change")
end

def should_show_edit_form_for_email_address_content_block(document_title, email_address)
  expect(page).to have_content("Change Email address")
  expect(page).to have_field("Title", with: document_title)
  expect(page).to have_field("Email address", with: email_address)
  expect(page).to have_content("Save and publish")
  expect(page).to have_content("Cancel")
end

Then("I should see errors for the required fields") do
  assert_text "Title can't be blank"

  required_fields = @schema.body["required"]
  required_fields.each do |required_field|
    assert_text "#{ContentObjectStore::ContentBlock::Edition.human_attribute_name("details_#{required_field}")} cannot be blank"
  end
  assert_text "Lead organisation cannot be blank"
end

Then("I should see a message that the {string} field is an invalid {string}") do |field_name, format|
  assert_text "#{ContentObjectStore::ContentBlock::Edition.human_attribute_name("details_#{field_name}")} is an invalid #{format.titleize}"
end

Then("I should see a permissions error") do
  assert_text "Permissions error"
end

Then("I should see the created event on the timeline") do
  assert_text "Email address created"
  expect(page).to have_selector(".timeline__byline", text: "by #{@user.name}")
end

Then("I should see the update on the timeline") do
  assert_text "Email address changed"
  expect(page).to have_selector(".timeline__byline", text: "by #{@user.name}", count: 2)
end

Then("I am asked to check my answers") do
  assert_text "Check your answers"
end

Then("I accept and publish") do
  click_on "Accept and publish"
end

When(/^dependent content exists for a content block$/) do
  @dependent_content = 10.times.map do |i|
    {
      "title": "Content #{i}",
      "document_type": "document",
      "links": {},
      "link_set_links": {},
      "base_path" => "/",
      "content_id": SecureRandom.uuid,
    }
  end

  @dependent_content.each_with_index do |item, i|
    stub_dependent_content(results: [item], total: @dependent_content.length, pages: @dependent_content.length, current_page: i + 1)
  end
end

Then(/^I should see the dependent content listed$/) do
  assert_text "Content appears in"

  @dependent_content.each do |item|
    assert_text item[:title]
    break if item == @dependent_content.last

    click_on "Next"
  end
end
