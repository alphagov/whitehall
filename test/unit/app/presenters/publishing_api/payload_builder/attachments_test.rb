require "test_helper"

module PublishingApi
  module PayloadBuilder
    class AttachmentsTest < ActiveSupport::TestCase
      test "ignores file attachments with missing asset variants" do
        attachment = build(:file_attachment)
        attachment.attachment_data.use_non_legacy_endpoints = true
        document = build(:news_article, :with_file_attachment, attachments: [attachment])

        assert_equal 0, PayloadBuilder::Attachments.for(document)[:attachments].count
      end

      test "allows file attachments that have all asset variants" do
        attachment = build(:file_attachment_with_assets)
        document = build(:news_article, :with_file_attachment, attachments: [attachment])

        assert_equal 1, PayloadBuilder::Attachments.for(document)[:attachments].count
      end

      test "allows non-file attachments" do
        attachment = build(:external_attachment)
        document = build(:news_article, :with_file_attachment, attachments: [attachment])

        assert_equal 1, PayloadBuilder::Attachments.for(document)[:attachments].count
      end
    end
  end
end
