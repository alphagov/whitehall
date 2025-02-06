def create_schema(fields)
  {
    "type" => "object",
    "required" => fields.select { |f| f["required"] == "true" }.map { |f| f["field"] },
    "additionalProperties" => false,
    "properties" => fields.map { |f|
      [f["field"], { "type" => f["type"], "format" => f["format"] }]
    }.to_h,
  }
end
