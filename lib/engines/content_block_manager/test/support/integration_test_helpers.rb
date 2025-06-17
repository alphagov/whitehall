module ContentBlockManager::IntegrationTestHelpers
  def stub_request_for_schema(block_type, subschemas: [], fields: nil)
    schema = stub(
      id: "content_block_type",
      fields: fields || [
        stub(:field, name: "foo", component_name: "string", enum_values: nil, default_value: nil, is_required?: false),
        stub(:field, name: "bar", component_name: "string", enum_values: nil, default_value: nil, is_required?: false),
      ],
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
      embeddable_fields: [],
      embeddable_as_block?: false,
    )
    subschemas.each do |subschema|
      schema.stubs(:subschema).with(subschema.id).returns(subschema)
    end
    ContentBlockManager::ContentBlock::Schema.stubs(:find_by_block_type).with(block_type).returns(schema)
    schema
  end
end
