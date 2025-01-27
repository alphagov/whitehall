require "test_helper"

class ContentBlockManager::ContentBlockFieldDiffTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:user) { create("user") }
  let(:organisation) { build(:organisation) }
  let(:document) { build(:content_block_document, :email_address) }

  describe "#all_for_edition" do
    describe "when there are no changes" do
      it "returns nil" do
        Current.user = user
        create(
          :content_block_edition,
          creator: user,
          document:,
          title: "same title",
          instructions_to_publishers: "same instructions",
          details: { "email_address": "old@example.com" },
          organisation:,
        )
        new_edition = create(
          :content_block_edition,
          creator: user,
          document:,
          title: "same title",
          instructions_to_publishers: "same instructions",
          details: { "email_address": "old@example.com" },
          organisation:,
        )

        new_edition.publish!

        assert_equal ContentBlockManager::ContentBlock::FieldDiff.all_for_edition(edition: new_edition), nil
      end
    end
    describe "when all changeable fields have changed" do
      it "provides changes in correct order" do
        new_organisation = build(:organisation)
        Current.user = user
        _previous_edition = create(
          :content_block_edition,
          creator: user,
          document:,
          title: "same title",
          instructions_to_publishers: "same instructions",
          details: { "email_address": "old@example.com" },
          organisation:,
        )
        new_edition = create(
          :content_block_edition,
          creator: user,
          document:,
          title: "new title",
          instructions_to_publishers: "new instructions",
          details: { "email_address": "new@example.com" },
          state: "draft",
          organisation: new_organisation,
        )

        new_edition.publish!

        expected_diffs = [
          { "field_name" => "title", "new_value" => "new title", "previous_value" => "same title" },
          { "field_name" => "email_address", "new_value" => "new@example.com", "previous_value" => "old@example.com" },
          { "field_name" => "lead_organisation", "new_value" => new_organisation.name, "previous_value" => organisation.name },
          { "field_name" => "instructions_to_publishers", "new_value" => "new instructions", "previous_value" => "same instructions" },
        ]

        assert_equal ContentBlockManager::ContentBlock::FieldDiff.all_for_edition(edition: new_edition).to_json, expected_diffs.to_json
      end
    end

    describe "when a top level field on an edition has changed" do
      %w[title instructions_to_publishers].each do |field|
        it "records the changes" do
          old_value = "old_value"
          new_value = "new_value"
          Current.user = user

          previous_edition = create(
            :content_block_edition,
            creator: user,
            document:,
            organisation:,
          )
          previous_edition.update!(field => old_value)
          new_edition = create(
            :content_block_edition,
            creator: user,
            document:,
            state: "draft",
            organisation:,
          )
          new_edition.update!(field => new_value)

          new_edition.publish!

          expected_diffs = [{ "field_name" => field, "new_value" => new_value, "previous_value" => old_value }]

          assert_equal ContentBlockManager::ContentBlock::FieldDiff.all_for_edition(edition: new_edition).to_json, expected_diffs.to_json
        end
      end

      describe "when the organisation has changed" do
        it "records the changes" do
          old_organisation = build(:organisation, id: "123", name: "Old Organisation")

          Current.user = user
          _previous_edition = create(
            :content_block_edition,
            creator: user,
            document:,
            organisation: old_organisation,
          )
          new_edition = create(
            :content_block_edition,
            creator: user,
            document:,
            state: "draft",
            organisation: build(:organisation, name: "New Organisation", id: "456"),
          )

          new_edition.publish!

          expected_diffs = [{ "field_name" => "lead_organisation", "new_value" => "New Organisation", "previous_value" => "Old Organisation" }]

          assert_equal ContentBlockManager::ContentBlock::FieldDiff.all_for_edition(edition: new_edition).to_json, expected_diffs.to_json
        end
      end
    end

    describe "when a field in the edition details has changed" do
      it "records the changes" do
        Current.user = user
        _previous_edition = create(
          :content_block_edition,
          creator: user,
          document:,
          title: "same title",
          instructions_to_publishers: "same instructions",
          details: { "email_address": "old@example.com" },
          organisation:,
        )
        new_edition = create(
          :content_block_edition,
          creator: user,
          document:,
          title: "same title",
          instructions_to_publishers: "same instructions",
          details: { "email_address": "new@example.com" },
          state: "draft",
          organisation:,
        )

        new_edition.publish!

        expected_diffs = [{ "field_name" => "email_address", "new_value" => "new@example.com", "previous_value" => "old@example.com" }]

        assert_equal ContentBlockManager::ContentBlock::FieldDiff.all_for_edition(edition: new_edition).to_json, expected_diffs.to_json
      end
    end
  end
end
