require_relative "../support/schema_helpers"

Given("a schema {string} exists with the following fields:") do |block_type, table|
  fields = table.hashes
  @schemas ||= {}
  body = create_schema_with_block_attributes(fields)
  @schemas[block_type] = build(:content_block_schema, block_type:, body:)
  ContentBlockManager::ContentBlock::Schema.stubs(:all).returns(@schemas.values)
end

And("the schema {string} has a subschema with the name {string} and the following fields:") do |block_type, subschema_name, table|
  fields = table.hashes
  schema = @schemas[block_type]
  schema.body["properties"]["block_attributes"]["properties"].merge!({
    subschema_name => {
      "type" => "object",
      "patternProperties" => {
        "^[a-z0-9]+(?:-[a-z0-9]+)*$" => create_schema(fields),
      },
    },
  })
  @schemas[block_type] = build(:content_block_schema, block_type:, body: schema.body)
  ContentBlockManager::ContentBlock::Schema.stubs(:all).returns(@schemas.values)
end

When("I click on the {string} schema") do |schema_id|
  @schema = @schemas[schema_id]
  ContentBlockManager::ContentBlock::Schema.expects(:find_by_block_type).with(schema_id).at_least_once.returns(@schema)
  choose @schema.name
  click_save_and_continue
end

Then("I should see a form for the schema") do
  expect(page).to have_text("Create #{@schema.name.downcase}")
end

Then("I should see all the schemas listed") do
  @schemas.values.each do |schema|
    expect(page).to have_content(schema.name)
  end
end
