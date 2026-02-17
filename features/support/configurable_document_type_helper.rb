require_relative "mocha"

Before do
  type_definition = JSON.parse(File.read(Rails.root.join("features/fixtures/test_configurable_document_type.json")))
  ConfigurableDocumentType.setup_test_types({ "test_type" => type_definition })
end
