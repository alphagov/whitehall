require "test_helper"

module PublishingApi
  module PayloadBuilder
    class AttachmentsTest < ActiveSupport::TestCase
      test "ignores file attachments with missing asset variants" do
        attachment = build(:file_attachment_with_no_assets)
        document = build(:publication, :with_alternative_format_provider, attachments: [attachment])

        assert_equal 0, PayloadBuilder::Attachments.for(document)[:attachments].count
      end

      test "allows file attachments that have all asset variants" do
        attachment = build(:file_attachment)
        document = build(:publication, :with_alternative_format_provider, attachments: [attachment])

        assert_equal 1, PayloadBuilder::Attachments.for(document)[:attachments].count
      end

      test "allows non-file attachments" do
        attachment = build(:external_attachment)
        document = build(:publication, :with_alternative_format_provider, attachments: [attachment])

        assert_equal 1, PayloadBuilder::Attachments.for(document)[:attachments].count
      end
    end
  end
end
