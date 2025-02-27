module ContentBlockManager::IntegrationTestHelpers
  def stub_request_for_schema(block_type, subschemas: [])
    schema = stub(
      id: "content_block_type",
      fields: %w[foo bar],
      name: "schema",
      body: {
        "properties" => {
          "foo" => { "type" => "string" },
          "bar" => { "type" => "string" },
        },
      },
      block_type:,
      permitted_params: %i[foo bar],
      subschemas:,
      config_for_field: {},
    )
    subschemas.each do |subschema|
      schema.stubs(:subschema).with(subschema.id).returns(subschema)
    end
    ContentBlockManager::ContentBlock::Schema.stubs(:find_by_block_type).with(block_type).returns(schema)
    schema
  end
end
