require "test_helper"

class StandardEditionBlockContentMergeTest < ActiveSupport::TestCase
  setup do
    test_type = build_configurable_document_type(
      "test_type",
      "schema" => {
        "properties" => {
          "test_attribute" => { "title" => "Test Attribute", "type" => "string" },
          "body" => { "title" => "Body", "type" => "string", "format" => "govspeak" },
          "count" => { "title" => "Count", "type" => "integer" },
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
end
