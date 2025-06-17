require "test_helper"

class ContentBlockManager::SchemaTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:body) { { "properties" => { "foo" => {}, "bar" => {}, "title" => {} } } }
  let(:schema) { build(:content_block_schema, :pension, body:) }

  it "generates a human-readable name" do
    assert_equal schema.name, "Pension"
  end

  it "generates a parameterized name for use in URLs" do
    assert_equal schema.parameter, "pension"
  end

  it "returns a block type" do
    assert_equal schema.block_type, "pension"
  end

  describe "#fields" do
    describe "when an order is not given in the config" do
      it "prioritises the title" do
        assert_equal schema.fields.map(&:name), %w[title foo bar]
      end
    end

    describe "when an order is given in the config" do
      before do
        ContentBlockManager::ContentBlock::Schema
          .stubs(:schema_settings)
          .returns({
            "schemas" => {
              "content_block_pension" => {
                "field_order" => %w[bar title foo],
              },
            },
          })
      end

      it "orders fields" do
        assert_equal schema.fields.map(&:name), %w[bar title foo]
      end

      describe "when a field is missing from the order" do
        before do
          ContentBlockManager::ContentBlock::Schema
            .stubs(:schema_settings)
            .returns({
              "schemas" => {
                "content_block_pension" => {
                  "field_order" => %w[bar foo],
                },
              },
            })
        end

        it "puts the missing field at the end" do
          assert_equal schema.fields.map(&:name), %w[bar foo title]
        end
      end
    end
  end

  describe "#required_fields" do
    describe "when there are no required fields" do
      it "returns an empty array" do
        assert_equal [], schema.required_fields
      end
    end

    describe "when there are required fields" do
      it "returns them as an array" do
        body["required"] = %w[foo]
        assert_equal %w[foo], schema.required_fields
      end
    end
  end

  describe "when a schema has embedded objects" do
    let(:body) do
      {
        "properties" => {
          "foo" => {
            "type" => "string",
          },
          "bar" => {
            "type" => "object",
            "patternProperties" => {
              "*" => {
                "type" => "object",
                "properties" => {
                  "my_string" => {
                    "type" => "string",
                  },
                  "something_else" => {
                    "type" => "string",
                  },
                },
              },
            },
          },
        },
      }
    end

    describe "#fields" do
      it "removes object fields" do
        assert_equal schema.fields.map(&:name), %w[foo]
      end
    end

    describe "#subschemas" do
      it "returns subschemas" do
        subschemas = schema.subschemas

        assert_equal subschemas.map(&:id), %w[bar]
      end
    end
  end

  describe ".permitted_params" do
    it "returns permitted params" do
      assert_equal schema.permitted_params, %w[title foo bar]
    end
  end

  describe ".valid_schemas" do
    it "returns the contents of the VALID_SCHEMA constant" do
      assert_equal ContentBlockManager::ContentBlock::Schema.valid_schemas, %w[
        pension
        contact
      ]
    end

    describe "when the show_all_content_block_types feature flag is turned off" do
      before do
        test_strategy = Flipflop::FeatureSet.current.test!
        test_strategy.switch!(:show_all_content_block_types, false)
      end

      it "only returns pensions" do
        assert_equal ContentBlockManager::ContentBlock::Schema.valid_schemas, %w[pension]
      end
    end
  end

  describe ".all" do
    let(:response) do
      {
        "something" => {},
        "something_else" => {},
        "content_block_foo" => {
          "definitions" => {
            "details" => {
              "properties" => {
                "foo_field" => {
                  "type" => "string",
                },
              },
            },
          },
        },
        "content_block_bar" => {
          "definitions" => {
            "details" => {
              "properties" => {
                "bar_field" => {
                  "type" => "string",
                },
                "bar_field2" => {
                  "type" => "string",
                },
              },
            },
          },
        },
        "content_block_invalid" => {},
      }
    end

    before(:all) do
      Services.publishing_api.expects(:get_schemas).once.returns(response)
      ContentBlockManager::ContentBlock::Schema.stubs(:is_valid_schema?).with(anything).returns(false)
      ContentBlockManager::ContentBlock::Schema.stubs(:is_valid_schema?).with(any_of("content_block_foo", "content_block_bar")).returns(true)
    end

    it "returns a list of schemas with the content block prefix" do
      schemas = ContentBlockManager::ContentBlock::Schema.all
      assert_equal schemas.map(&:id), %w[content_block_foo content_block_bar]
      fields = schemas.map(&:fields)
      assert_equal fields[0].map(&:name), %w[foo_field]
      assert_equal fields[1].map(&:name), %w[bar_field bar_field2]
    end

    it "memoizes the result" do
      # Mocha won't let us assert how many times something was called, so
      # given that we only expect Publishing API to be called once, let's
      # call our service method twice and assert that no errors were raised
      assert_nothing_raised do
        2.times { ContentBlockManager::ContentBlock::Schema.all }
      end
    end
  end

  describe ".find_by_block_type" do
    let(:block_type) { "pension" }
    let(:body) do
      {
        "properties" => {
          "email_address" => {
            "type" => "string",
            "format" => "email",
          },
        },
      }
    end

    setup do
      ContentBlockManager::ContentBlock::Schema.stubs(:all).returns([
        build(:content_block_schema, block_type:, body:),
        build(:content_block_schema, block_type: "something_else", body: {}),
      ])
    end

    test "it returns the schema when the block_type is valid" do
      schema = ContentBlockManager::ContentBlock::Schema.find_by_block_type(block_type)

      assert_equal schema.id, "content_block_#{block_type}"
      assert_equal schema.block_type, block_type
      assert_equal schema.fields.map(&:name), %w[email_address]
    end

    test "it throws an error when the schema  cannot be found for the block type" do
      block_type = "other_thing"

      assert_raises ArgumentError, "Cannot find schema for #{block_type}" do
        ContentBlockManager::ContentBlock::Schema.find_by_block_type(block_type)
      end
    end
  end

  describe ".is_valid_schema?" do
    it "returns true when the schema has correct prefix/suffix" do
      ContentBlockManager::ContentBlock::Schema.valid_schemas.each do |schema|
        schema_name = "#{ContentBlockManager::ContentBlock::Schema::SCHEMA_PREFIX}_#{schema}"
        assert ContentBlockManager::ContentBlock::Schema.is_valid_schema?(schema_name)
      end
    end

    it "returns false when given an invalid schema" do
      schema_name = "something_else"
      assert_equal ContentBlockManager::ContentBlock::Schema.is_valid_schema?(schema_name), false
    end

    it "returns false when the schema has correct prefix but a suffix that is not valid" do
      schema_name = "#{ContentBlockManager::ContentBlock::Schema::SCHEMA_PREFIX}_something"
      assert_equal ContentBlockManager::ContentBlock::Schema.is_valid_schema?(schema_name), false
    end
  end

  describe ".schema_settings" do
    let(:stub_schema) { stub("schema_settings") }

    before do
      YAML.expects(:load_file)
          .with(ContentBlockManager::ContentBlock::Schema::CONFIG_PATH)
          .returns(stub_schema)

      # This removes any memoized schema_settings, so we can be sure the stub gets returned
      ContentBlockManager::ContentBlock::Schema.instance_variable_set("@schema_settings", nil)
    end

    after do
      # Make sure we remove the stubbed schema_settings response after the tests in this block run
      ContentBlockManager::ContentBlock::Schema.instance_variable_set("@schema_settings", nil)
    end

    it "should return the schema settings" do
      assert_equal ContentBlockManager::ContentBlock::Schema.schema_settings, stub_schema
    end
  end

  describe "when a schema has embedded objects" do
    let(:body) do
      {
        "properties" => {
          "foo" => {
            "type" => "string",
          },
          "bar" => {
            "type" => "object",
            "patternProperties" => {
              "*" => {
                "type" => "object",
                "properties" => {
                  "my_string" => {
                    "type" => "string",
                  },
                  "something_else" => {
                    "type" => "string",
                  },
                },
              },
            },
          },
        },
      }
    end

    describe "#fields" do
      it "removes object fields" do
        assert_equal schema.fields.map(&:name), %w[foo]
      end
    end
  end

  describe "#embeddable_fields" do
    describe "when config exists for a schema" do
      before do
        ContentBlockManager::ContentBlock::Schema
          .stubs(:schema_settings)
          .returns({
            "schemas" => {
              schema.id => {
                "embeddable_fields" => %w[something else],
              },
            },
          })
      end

      it "returns the config values" do
        assert_equal schema.embeddable_fields, %w[something else]
      end
    end

    describe "when config does not exist for a schema" do
      before do
        ContentBlockManager::ContentBlock::Schema
          .stubs(:schema_settings)
          .returns({})
      end

      it "returns an empty array" do
        assert_equal schema.embeddable_fields, []
      end
    end
  end

  describe "#subschemas_for_group" do
    let(:group_1_subschemas) do
      [
        stub(:subschema, group: "group_1"),
        stub(:subschema, group: "group_1"),
      ]
    end

    let(:subschemas) do
      [
        *group_1_subschemas,
        stub(:subschema, group: nil),
        stub(:subschema, group: nil),
      ]
    end

    before do
      schema.stubs(:subschemas).returns(subschemas)
    end

    it "returns subschemas for a group" do
      assert_equal schema.subschemas_for_group("group_1"), group_1_subschemas
    end

    it "returns an empty array when no subschemas can be found" do
      assert_equal schema.subschemas_for_group("group_2"), []
    end
  end

  describe "#embeddable_as_block?" do
    describe "when the embeddable_as_block config value is set" do
      before do
        ContentBlockManager::ContentBlock::Schema
          .stubs(:schema_settings)
          .returns({
            "schemas" => {
              schema.id => {
                "embeddable_as_block" => true,
              },
            },
          })
      end

      it "returns true" do
        assert schema.embeddable_as_block?
      end
    end

    describe "when the embeddable_as_block config value is not set" do
      before do
        ContentBlockManager::ContentBlock::Schema
          .stubs(:schema_settings)
          .returns({
            "schemas" => {
              schema.id => {},
            },
          })
      end

      it "returns false" do
        assert_not schema.embeddable_as_block?
      end
    end
  end
end
