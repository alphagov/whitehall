require_relative "../support/schema_helpers"

Given("a schema {string} exists with the following fields:") do |block_type, table|
  fields = table.hashes
  @schemas ||= {}
  body = create_schema(fields)
  @schemas[block_type] = build(:content_block_schema, block_type:, body:)
  ContentBlockManager::ContentBlock::Schema.stubs(:all).returns(@schemas.values)
end

And("the schema {string} has a subschema with the name {string} and the following fields:") do |block_type, subschema_name, table|
  fields = table.hashes
  schema = @schemas[block_type]
  body = schema.body.deep_merge({
    "properties" => {
      subschema_name => {
        "type" => "object",
        "patternProperties" => {
          "^[a-z0-9]+(?:-[a-z0-9]+)*$" => create_schema(fields),
        },
      },
    },
  })
  @schemas[block_type] = build(:content_block_schema, block_type:, body:)
  ContentBlockManager::ContentBlock::Schema.stubs(:all).returns(@schemas.values)
end

When("I click on the {string} schema") do |schema_id|
  @schema = @schemas[schema_id]
  ContentBlockManager::ContentBlock::Schema.expects(:find_by_block_type).with(schema_id).at_least_once.returns(@schema)
  choose @schema.name
  click_save_and_continue
end

When("I click on the {string} subschema") do |schema_id|
  schema = @schemas.values.last
  subschema = schema.subschema(schema_id)
  choose subschema.name.singularize
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

Then("I should see all the subschemas for {string} listed") do |group|
  schema = @schemas.values.last
  schema&.subschemas_for_group(group)&.each do |subschema|
    expect(page).to have_content(subschema.name.singularize)
  end
end

And("the schema {string} has a group {string} with the following subschemas:") do |block_type, group, table|
  subschemas = table.raw.first
  schema = @schemas[block_type]

  subschemas.each do |subschema_id|
    subschema = schema.subschema(subschema_id)
    subschema.stubs(:group).returns(group)
  end
end
