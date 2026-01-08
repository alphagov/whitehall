require "test_helper"

class StandardEditionBlockContentMergeTest < ActiveSupport::TestCase
  setup do
    test_type = build_configurable_document_type(
      "test_type",
      {
        "forms" => {
          "documents" => {
            "test_attribute" => { "title" => "Test Attribute", "block" => "default_string" },
            "body" => { "title" => "Body", "block" => "govspeak" },
            "count" => { "title" => "Count", "block" => "image_select" },
          },
        },
        "schema" => {
          "attributes" => {
            "test_attribute" => { "type" => "string" },
            "body" => { "type" => "string" },
            "count" => { "type" => "integer" },
          },
        },
      },
    )
    ConfigurableDocumentType.setup_test_types(test_type)

    @edition = create(
      :standard_edition,
      configurable_document_type: "test_type",
      block_content: {
        "test_attribute" => "Hello",
        "body" => "# Heading",
        "some_old_field" => "this should be deleted", # invalid per schema
      },
    )
  end

  test "overwriting: updates the value for an existing valid key" do
    @edition.update!(block_content: { "test_attribute" => "Bonjour" })

    assert_equal "Bonjour", @edition.reload.block_content["test_attribute"]
  end

  test "ignoring existing: preserves other existing valid keys not present in the update" do
    @edition.update!(block_content: { "count" => 3 }) # only add a new valid key

    bc = @edition.reload.block_content
    assert_equal "# Heading", bc["body"] # preserved
    assert_equal "Hello",     bc["test_attribute"] # preserved
    assert_equal 3,           bc["count"]          # added
  end

  test "deleting old invalid: removes previously-stored keys not in the schema" do
    @edition.update!(block_content: { "test_attribute" => "Hi" })

    assert_nil @edition.reload.block_content["some_old_field"], "invalid legacy key should be pruned"
  end

  test "ignoring new invalid: ignores newly-supplied keys not in the schema" do
    @edition.update!(block_content: { "unrecognised_field" => "should be ignored" })

    bc = @edition.reload.block_content
    assert_nil bc["unrecognised_field"], "invalid new key should not be persisted"
    # existing content should still be intact
    assert_equal "Hello", bc["test_attribute"]
    assert_equal "# Heading", bc["body"]
  end

  test "setter: `block_content=` merges and filters on `save!`" do
    @edition.block_content = {
      "test_attribute" => "Bonjour", # overwrite existing valid key
      "unrecognised_key" => "should be ignored", # invalid per schema
    }

    @edition.save!

    bc = @edition.reload.block_content
    assert_equal "Bonjour", bc["test_attribute"] # merged/overwritten
    assert_equal "# Heading", bc["body"] # preserved
    assert_nil bc["unrecognised_key"], "invalid new key should not persist"
  end

  test "`update` (non-bang): merges and filters" do
    assert @edition.update(
      block_content: {
        "test_attribute" => "Hola", # overwrite
        "unrecognised_key" => "ignored", # invalid
      },
    )

    bc = @edition.reload.block_content
    assert_equal "Hola",      bc["test_attribute"]
    assert_equal "# Heading", bc["body"]
    assert_nil bc["unrecognised_key"]
  end

  test "`update!`: merges and filters" do
    @edition.update!(
      block_content: {
        "test_attribute" => "Ciao", # overwrite
        "unrecognised_key" => "ignored", # invalid
      },
    )

    bc = @edition.reload.block_content
    assert_equal "Ciao",      bc["test_attribute"]
    assert_equal "# Heading", bc["body"]
    assert_nil bc["unrecognised_key"]
  end

  # Is this test needed anymore? We think now that we're using flattened data structures,
  # the above tests cover all addition/overwriting/deletion scenarios, and this 'nesting'
  # test is now redundant.
  test "deep merge: updates nested keys and filters invalid ones when assigned via ActionController::Parameters" do
    nested_type = build_configurable_document_type(
      "nested_type",
      "schema" => {
        "attributes" => {
          "body" => { "type" => "string" },
          "summary" => { "type" => "string" },
          "audience" => { "type" => "string" },
          "meta" => { "type" => "object" },
          # "count" => { "type" => "integer" },
        },
      },
    )
    ConfigurableDocumentType.setup_test_types(nested_type)

    edition = create(
      :standard_edition,
      configurable_document_type: "nested_type",
      block_content: {
        "body" => "Start",
        "summary" => "old summary",
        "audience" => "public",
        "meta" => {
          "info" => "some info",
          "details" => "some details",
          "bool" => true,
        },
        # "count" => 1,
        "junk" => "should be removed", # invalid per schema
      },
    )

    # Simulate controller-style assignment (attributes object) rather than a plain Hash
    params = ActionController::Parameters.new(
      "block_content" => {
        "summary" => "new summary", # overwrite nested valid key
        # "count" => 2,                        # overwrite nested-nested valid key
        "invalid_nested" => "ignore me",     # invalid nested key
        "unknown" => "ignore me too", # invalid nested key at level 1
        "meta" => {
          "info" => "updated info",
          "details" => "updated details",
          "bool" => false,
        },
        "not_in_schema" => "nope", # invalid top-level key
      },
    ).permit!

    assert edition.update(params)

    bc = edition.reload.block_content
    # top-level preserved
    assert_equal "Start", bc["body"]

    # nested object merged
    assert_equal "new summary", bc["summary"]
    assert_equal "public",      bc["audience"] # preserved
    # assert_equal 2,             bc["count"]    # updated

    assert_equal({
      "info" => "updated info",
      "details" => "updated details",
      "bool" => false,
    }, bc["meta"].to_h)

    # invalid keys filtered out
    assert_nil bc["junk"]
    assert_nil bc["unknown"]
    assert_nil bc["invalid_nested"]
    assert_nil bc["not_in_schema"]
  end
end
