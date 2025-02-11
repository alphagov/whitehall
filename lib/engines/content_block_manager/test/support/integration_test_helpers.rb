module ContentBlockManager::IntegrationTestHelpers
  def stub_request_for_schema(block_type)
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
      subschemas: [],
    )
    ContentBlockManager::ContentBlock::Schema.stubs(:find_by_block_type).with(block_type).returns(schema)
    schema
  end
end
