require "test_helper"
require "rake"

class UpdateVersionDiffsTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  teardown do
    Rake::Task["content_block_manager:update_version_diffs"].reenable
  end

  it "updates the version diffs" do
    document = create(:content_block_document, :email_address)
    organisation = create(:organisation)

    edition_1 = create(:content_block_edition, document:, title: "Edition 1", details: { "email_address" => "something@something.com" }, organisation:, created_at: Time.zone.now - 7.days)
    version_1 = create(:content_block_version, event: "updated", item_type: "ContentBlockManager::ContentBlock::Edition", item: edition_1)

    edition_2 = create(:content_block_edition, document:, title: "Edition 2", details: { "email_address" => "something@else.com" }, organisation:, created_at: Time.zone.now - 4.days)
    version_2 = create(:content_block_version, event: "updated", item_type: "ContentBlockManager::ContentBlock::Edition", item: edition_2)

    edition_3 = create(:content_block_edition, document:, title: "Edition 3", details: { "email_address" => "something@else.org" }, organisation:, created_at: Time.zone.now - 3.days)
    version_3 = create(:content_block_version, event: "updated", item_type: "ContentBlockManager::ContentBlock::Edition", item: edition_3)

    edition_4 = create(:content_block_edition, document:, title: "Edition 4", details: { "email_address" => "another@thing.org" }, organisation:, created_at: Time.zone.now - 2.days)
    version_4 = create(:content_block_version, event: "updated", item_type: "ContentBlockManager::ContentBlock::Edition", item: edition_4)

    Rake.application.invoke_task("content_block_manager:update_version_diffs")

    assert_nil version_1.reload.field_diffs
    assert_equal ({
      "title" => ["Edition 1", "Edition 2"],
      "details" => {
        "email_address" => %w[something@something.com something@else.com],
      },
    }), version_2.reload.field_diffs
    assert_equal ({
      "title" => ["Edition 2", "Edition 3"],
      "details" => {
        "email_address" => %w[something@else.com something@else.org],
      },
    }), version_3.reload.field_diffs
    assert_equal ({
      "title" => ["Edition 3", "Edition 4"],
      "details" => {
        "email_address" => %w[something@else.org another@thing.org],
      },
    }), version_4.reload.field_diffs
  end
end
