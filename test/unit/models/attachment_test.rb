require "test_helper"

class AttachemntTest < ActiveSupport::TestCase
  test ".publishing_api_details has file_attachment_asset attributes" do
    attachment = build(:file_attachment, attachable: build(:news_article))

    output = attachment.publishing_api_details
    assert_equal output.keys,
                 %i[attachment_type id title url accessible alternative_format_contact_email content_type filename]
  end

  test ".publishing_api_details includes publication attachment details for " \
       "attachables that allow references" do
    attachment = build(:file_attachment, attachable: build(:publication))

    output = attachment.publishing_api_details
    assert_not_empty output.keys & %i[unnumbered_command_paper unnumbered_hoc_paper]
  end
end
