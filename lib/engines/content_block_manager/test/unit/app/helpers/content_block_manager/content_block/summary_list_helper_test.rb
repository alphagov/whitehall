require "test_helper"

class ContentBlockManager::ContentBlock::SummaryListHelperTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL
  include ContentBlockManager::ContentBlock::SummaryListHelper

  let(:input) do
    {
      "string_item" => "Item",
      "array_items" => ["Item 1", "Item 2"],
      "array_of_objects_items" => [
        {
          "title" => "Item 1 Title",
          "description" => "Item 1 Description",
        },
        {
          "title" => "Item 2 Title",
          "description" => "Item 2 Description",
        },
      ],
      "object_item" => {
        "title" => "Object Title",
        "description" => "Object Description",
      },
    }
  end

  describe "#first_class_items" do
    it "returns any string items and flattens out non-nested arrays" do
      expected = {
        "string_item" => "Item",
        "array_items/0" => "Item 1",
        "array_items/1" => "Item 2",
      }

      assert_equal first_class_items(input), expected
    end
  end

  describe "#nested_items" do
    it "returns nested items" do
      expected = {
        "array_of_objects_items" => [
          {
            "title" => "Item 1 Title",
            "description" => "Item 1 Description",
          },
          {
            "title" => "Item 2 Title",
            "description" => "Item 2 Description",
          },
        ],
        "object_item" => {
          "title" => "Object Title",
          "description" => "Object Description",
        },
      }

      assert_equal nested_items(input), expected
    end
  end

  describe "#key_to_title" do
    it "returns a titlelized version of a key without an index" do
      assert_equal key_to_title("item"), "Item"
    end

    it "returns a titleized version with a count when an index is present" do
      assert_equal key_to_title("items/1"), "Item 2"
    end

    describe "when there is a translation for the key" do
      it "returns translated key" do
        I18n.expects(:t).with("content_block_edition.details.labels.object_type.item", default: "Item").returns("Item translated")

        assert_equal key_to_title("item", "object_type"), "Item translated"
      end
    end
  end
end
