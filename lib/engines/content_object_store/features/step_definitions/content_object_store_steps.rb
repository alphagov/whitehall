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
