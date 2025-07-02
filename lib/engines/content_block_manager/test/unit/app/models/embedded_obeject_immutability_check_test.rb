require "test_helper"

class ContentBlockManager::EmbeddedObjectImmutabilityCheckTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:field_reference) { %w[foo bar baz] }
  let(:checker) { ContentBlockManager::EmbeddedObjectImmutabilityCheck.new(edition:, field_reference:) }

  describe "#can_be_deleted?" do
    describe "when an edition is given" do
      let(:edition) { build(:content_block_edition, :contact, details:) }

      describe "and something exists in the field reference" do
        let(:details) do
          {
            "foo" => {
              "bar" => {
                "baz" => [
                  { "title" => "Item 1" },
                  { "title" => "Item 2" },
                ],
              },
            },
          }
        end

        it "returns false if an item exists at that index" do
          assert_equal false, checker.can_be_deleted?(0)
          assert_equal false, checker.can_be_deleted?(1)
        end

        it "returns true if an item does not exist at that index" do
          assert_equal true, checker.can_be_deleted?(2)
        end
      end

      describe "and nothing exists in the field reference" do
        let(:details) { {} }

        it "returns true" do
          assert_equal true, checker.can_be_deleted?(0)
        end
      end
    end

    describe "when no edition is given" do
      let(:edition) { nil }

      it "returns true" do
        assert_equal true, checker.can_be_deleted?(0)
      end
    end
  end
end
