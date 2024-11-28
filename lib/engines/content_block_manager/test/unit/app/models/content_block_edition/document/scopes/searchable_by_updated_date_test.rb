require "test_helper"

class ContentBlockManager::SearchableByUpdatedDateTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe ".from_date" do
    test "finds documents updated from and including this date" do
      filter_date_time = 1.day.before(Time.zone.now)
      matching_document_1 = create(:content_block_document, :email_address)
      matching_document_1.updated_at = filter_date_time
      matching_document_1.save!
      matching_document_2 = create(:content_block_document, :email_address)
      matching_document_2.updated_at = Time.zone.now
      matching_document_2.save!

      not_matching_document = create(:content_block_document, :email_address)
      not_matching_document.updated_at = 2.days.before(Time.zone.now)
      not_matching_document.save!

      assert_equal [matching_document_1, matching_document_2], ContentBlockManager::ContentBlock::Document.from_date(filter_date_time)
    end
  end

  describe ".to_date" do
    test "finds documents updated up to and including this date" do
      filter_date_time = 1.day.before(Time.zone.now)
      matching_document_1 = create(:content_block_document, :email_address)
      matching_document_1.updated_at = filter_date_time
      matching_document_1.save!
      matching_document_2 = create(:content_block_document, :email_address)
      matching_document_2.updated_at = 2.days.before(Time.zone.now)
      matching_document_2.save!

      not_matching_document = create(:content_block_document, :email_address)
      not_matching_document.updated_at = Time.zone.now
      not_matching_document.save!

      assert_equal [matching_document_1, matching_document_2], ContentBlockManager::ContentBlock::Document.to_date(filter_date_time)
    end
  end
end
