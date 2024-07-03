Given("a schema {string} exists") do |schema_id|
  @schemas ||= {}
  @schemas[schema_id] = ContentObjectStore::Schema.new(schema_id)
  ContentObjectStore::SchemaService.stubs(:valid_schemas).returns(@schemas.values)
end

When("I access the create object page") do
  visit content_object_store.new_content_object_store_content_block_edition_path
end

Then("I should see all the schemas listed") do
  @schemas.values.each do |schema|
    expect(page).to have_content(schema.name)
  end
end
