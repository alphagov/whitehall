require "test_helper"

class ContentBlockManager::DiffableTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:document) { create(:content_block_document, :email_address) }

  let(:organisation) { create(:organisation) }
  let(:previous_edition) do
    create(:content_block_edition, document:, created_at: Time.zone.now - 2.days, organisation:)
  end
  let(:edition) do
    create(:content_block_edition, document:, organisation:)
  end

  describe "#generate_diff" do
    describe "when the document is a new block" do
      before do
        edition.document.expects(:is_new_block?).returns(true)
      end

      it "returns an empty hash" do
        assert_equal edition.generate_diff, {}
      end
    end

    describe "when the document is not a new block" do
      before do
        edition.document.expects(:is_new_block?).returns(false)
      end

      it "returns a diff if the title has changed" do
        previous_edition.title = "Something old"
        previous_edition.save!

        edition.title = "Something new"
        edition.save!

        expected_diff = { "title" => ["Something old", "Something new"] }

        assert_equal edition.generate_diff, expected_diff
      end

      it "returns a details diff if any items in the details have changed" do
        previous_edition.details = { "email_address": "old@example.com" }
        previous_edition.save!

        edition.details = { "email_address": "new@example.com" }
        edition.save!

        expected_diff = { "details" => { "email_address" => %w[old@example.com new@example.com] } }

        assert_equal edition.generate_diff, expected_diff
      end

      it "returns a nested details diff for any changes to nested objects" do
        previous_edition.details = {
          "rates" => {
            "rate-1" => {
              "amount" => "£124.55",
            },
            "other-rate" => {
              "amount" => "£5",
            },
          },
        }
        previous_edition.save!

        edition.details = {
          "rates" => {
            "rate-1" => {
              "amount" => "£124.22",
            },
            "rate-2" => {
              "amount" => "£99.50",
            },
          },
        }
        edition.save!

        expected_diffs = {
          "details" => {
            "rates" => {
              "rate-1" => {
                "amount" => %w[£124.55 £124.22],
              },
              "other-rate" => {
                "amount" => ["£5", nil],
              },
              "rate-2" => {
                "amount" => [nil, "£99.50"],
              },
            },
          },
        }

        assert_equal edition.generate_diff, expected_diffs
      end

      it "returns a diff if the organisation has changed" do
        old_organisation = create(:organisation, name: "One Organisation")
        new_organisation = create(:organisation, name: "Another Organisation")

        previous_edition.organisation = old_organisation
        previous_edition.save!

        edition.organisation = new_organisation
        edition.save!

        expected_diff = { "lead_organisation" => ["One Organisation", "Another Organisation"] }

        assert_equal edition.generate_diff, expected_diff
      end

      it "returns a diff if instructions_to_publishers has changed" do
        previous_edition.instructions_to_publishers = "Old instructions"
        previous_edition.save!

        edition.instructions_to_publishers = "New instructions"
        edition.save!

        expected_diff = { "instructions_to_publishers" => ["Old instructions", "New instructions"] }

        assert_equal edition.generate_diff, expected_diff
      end
    end
  end
end
