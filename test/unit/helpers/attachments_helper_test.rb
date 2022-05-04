require "test_helper"

class AttachmentsHelperTest < ActionView::TestCase
  test "CSV attachments attached to editions can be previewed" do
    csv_on_edition = create(:csv_attachment, attachable: create(:edition))
    assert previewable?(csv_on_edition)
  end

  test "non-CSV attachments are not previewable" do
    non_csv_on_edition = create(:file_attachment, attachable: create(:edition))
    assert_not previewable?(non_csv_on_edition)
  end

  test "CSV attachments attached to non-editions are not previewable" do
    csv_on_policy_group = create(:csv_attachment, attachable: create(:policy_group))
    assert_not previewable?(csv_on_policy_group)
  end

  test "Attachments belonging to organisations taking part in the accessible format request pilot can be identified" do
    GovukPublishingComponents::Presenters::AttachmentHelper.stub_const(:EMAILS_IN_ACCESSIBLE_FORMAT_REQUEST_PILOT, ["in_pilot@example.com"]) do
      assert participating_in_accessible_format_request_pilot?("in_pilot@example.com")
    end
  end

  test "Attachments belonging to organisations not taking part in the accessible format request pilot can be identified" do
    GovukPublishingComponents::Presenters::AttachmentHelper.stub_const(:EMAILS_IN_ACCESSIBLE_FORMAT_REQUEST_PILOT, []) do
      assert_not participating_in_accessible_format_request_pilot?("not_in_pilot@example.com")
    end
  end
end
