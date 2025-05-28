def create_schema(fields)
  {
    "type" => "object",
    "required" => fields.select { |f| f["required"] == "true" }.map { |f| f["field"] },
    "additionalProperties" => false,
    "properties" => fields.map { |f|
      [f["field"], { "type" => f["type"], "format" => f["format"], "enum" => f["enum"]&.split(","), "pattern" => f["pattern"] }.compact_blank!]
    }.to_h,
  }
end

def create_schema_with_block_attributes(fields)
  {
    "type" => "object",
    "additionalProperties" => false,
    "properties" => {
      "block_attributes" => {
        "type" => "object",
        "required" => fields.select { |f| f["required"] == "true" }.map { |f| f["field"] },
        "properties" => fields.map { |f|
          [f["field"], { "type" => f["type"], "format" => f["format"], "enum" => f["enum"]&.split(","), "pattern" => f["pattern"] }.compact_blank!]
        }.to_h,
      },
    },
  }
end
