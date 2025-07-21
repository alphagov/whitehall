require "test_helper"

class ContentBlockManager::ContentBlock::TranslationHelperTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL
  include ContentBlockManager::ContentBlock::TranslationHelper

  describe "humanized_label" do
    describe "when there is a 'root object'" do
      it "prepends the root object to the 'relative label key'" do
        I18n.expects(:t)
          .with(
            "content_block_edition.details.labels.root_object.nested_object.field_name",
            default: "Nested object.field name",
          )
          .returns("Field label")

        assert_equal(
          "Field label",
          humanized_label(relative_key: "nested_object.field_name", root_object: "root_object"),
        )
      end
    end

    describe "when there is not a 'root object'" do
      it "uses only the 'relative label key" do
        I18n.expects(:t)
          .with(
            "content_block_edition.details.labels.nested_object.field_name",
            default: "Nested object.field name",
          )
          .returns("Field label")

        assert_equal(
          "Field label",
          humanized_label(relative_key: "nested_object.field_name"),
        )
      end
    end

    it "strips hyphens from the 'default' passed to I18n.t" do
      I18n.expects(:t)
        .with(
          "content_block_edition.details.labels.nested_object.field-name",
          default: "Nested object.field name",
        )
        .returns("Field label")

      assert_equal(
        "Field label",
        humanized_label(relative_key: "nested_object.field-name"),
      )
    end
  end

  describe "translated_value" do
    it "calls translation config with value" do
      I18n.expects(:t)
          .with("content_block_edition.details.values.field value", default: "field value")
          .returns("field value")

      assert_equal "field value", translated_value("field value")
    end
  end
end
