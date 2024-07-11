Given("a schema {string} exists with the following fields:") do |block_type, table|
  data = table.raw
  @schemas ||= {}
  properties = data.flatten.index_with { |_field| {} }
  @schemas[block_type] = build(:content_block_schema, block_type:, body: { "properties" => properties })
  ContentObjectStore::ContentBlockSchema.stubs(:all).returns(@schemas.values)
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
  ContentObjectStore::ContentBlockSchema.expects(:find_by_block_type).with(schema_id).at_least_once.returns(@schema)
  click_link @schema.name
end

Then("I should see a form for the schema") do
  expect(page).to have_content(@schema.name)
end

When("I complete the form") do
  @title = "My title"
  @details = @schema.fields.index_with { |f| "#{f} content" }

  fill_in "Title", with: @title
  @details.keys.each do |k|
    fill_in "content_object_store_content_block_edition_details_#{k}", with: @details[k]
  end
  click_on "Save and continue"
end

Then("the edition should have been created successfully") do
  assert_text "#{@schema.name} created successfully"

  edition = ContentObjectStore::ContentBlockEdition.all.last

  assert_not_nil edition
  assert_not_nil edition.document

  assert_equal edition.title, @title
  @details.keys.each do |k|
    assert_equal edition.details[k], @details[k]
  end
end

Given("an email address content block has been created") do
  @content_blocks ||= []
  @email_address = "foo@example.com"
  @content_block = create(:content_block_edition, :email_address, details: { email_address: @email_address })
  @content_blocks.push(@content_block)
end

When("I visit the page for the content block") do
  visit content_object_store.content_object_store_content_block_edition_path(@content_block)
end

When("I visit the object store") do
  visit content_object_store.content_object_store_content_block_editions_path
end

Then("I should see the details for all content blocks") do
  assert_text "All content blocks"

  @content_blocks.each do |block|
    should_show_summary_card_for_email_address_content_block(
      block.document.title,
      block.details[:email_address]
    )
  end
end

When("I click to view the content block") do
  click_link href: content_object_store.content_object_store_content_block_edition_path(@content_block)
end

Then("I should see the details for the email address content block") do
  assert_text "Manage an Email address"

  should_show_summary_list_for_email_address_content_block(
    @content_block.document.title,
    @email_address
  )
end

When("I click the first change link") do
  first_link = find("a[href='#{content_object_store.edit_content_object_store_content_block_edition_path(@content_block)}']", match: :first)
  first_link.click
end

Then("I should see the edit form") do
  should_show_edit_form_for_email_address_content_block(
    @content_block.document.title,
    @email_address
  )
end

When("I fill out the form") do
  fill_in "Title", with: "Changed title"
  fill_in "Email address", with: "changed@example.com"
  click_on "Save and continue"
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
  expect(page).to have_selector(".govuk-summary-list__actions", text: "Change")
end

def should_show_edit_form_for_email_address_content_block(document_title, email_address)
  expect(page).to have_content("Change Email address")
  expect(page).to have_field('Title', with: document_title)
  expect(page).to have_field("Email address", with: email_address)
  expect(page).to have_content("Save and continue")
  expect(page).to have_content("Cancel")
end
