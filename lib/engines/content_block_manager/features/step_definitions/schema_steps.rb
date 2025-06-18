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

And("a schema {string} exists:") do |block_type, json|
  @schemas ||= {}
  body = JSON.parse(json)
  @schema = build(:content_block_schema, block_type:, body:)
  @schemas[block_type] = @schema
  ContentBlockManager::ContentBlock::Schema.stubs(:all).returns(@schemas.values)
end

And("the schema has a subschema {string}:") do |subschema_name, json|
  @subschemas ||= {}
  @subschemas[subschema_name] = JSON.parse(json)
  @schema.body["properties"][subschema_name] = {
    "type" => "object",
    "patternProperties" => {
      "^[a-z0-9]+(?:-[a-z0-9]+)*$" => @subschemas[subschema_name],
    },
  }
  @schema = build(:content_block_schema, block_type: @schema.block_type, body: @schema.body)
  @schemas[@schema.block_type] = @schema
  ContentBlockManager::ContentBlock::Schema.stubs(:all).returns(@schemas.values)
end
