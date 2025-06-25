require "test_helper"

class ContentBlockManager::ContentBlock::TranslationHelperTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL
  include ContentBlockManager::ContentBlock::TranslationHelper

  describe "humanized_label" do
    describe "when there is an object type" do
      it "calls translation config with type" do
        I18n.expects(:t)
            .with("content_block_edition.details.labels.object_type.field_name", default: "Field name")
            .returns("Field name")

        assert_equal "Field name", humanized_label("field_name", "object_type")
      end
    end

    describe "when there is not an object type" do
      it "calls translation config without type" do
        I18n.expects(:t)
            .with("content_block_edition.details.labels.field_name", default: "Field name")
            .returns("Field name")

        assert_equal "Field name", humanized_label("field_name", nil)
      end
    end

    it "strips hyphens" do
      I18n.expects(:t)
          .with("content_block_edition.details.labels.field-name", default: "Field name")
          .returns("Field name")

      assert_equal "Field name", humanized_label("field-name", nil)
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
