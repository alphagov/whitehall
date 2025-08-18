require "test_helper"

class FileAttachmentTest < ActiveSupport::TestCase
  def attachment
    @attachment ||= build(:file_attachment)
  end

  def assert_delegated(attachment, method)
    attachment.attachment_data.expects(method).returns(method.to_s)
    assert_equal method.to_s, attachment.send(method)
  end

  test "asks data for file specific information" do
    assert_delegated attachment, :url
    assert_delegated attachment, :content_type
    assert_delegated attachment, :pdf?
    assert_delegated attachment, :file_extension
    assert_delegated attachment, :file_size
    assert_delegated attachment, :number_of_pages
    assert_delegated attachment, :file
    assert_delegated attachment, :filename
  end

  test "html? is false" do
    assert_not attachment.html?
  end

  test "should be invalid if an attachment already exists on the attachable with the same filename" do
    attachable = create(:policy_group, attachments: [build(:file_attachment, file: file_fixture("whitepaper.pdf"))])
    duplicate  = build(:file_attachment, file: file_fixture("whitepaper.pdf"), attachable:)

    assert_not duplicate.valid?(:user_input)
    assert_match %r{with name "whitepaper.pdf" already attached to document}, duplicate.attachment_data.errors[:file].first
  end

  test "unique filename check does not explode if file is not present" do
    attachable = create(:policy_group, attachments: [build(:file_attachment)])
    attachment = build(:file_attachment, attachable:, file: nil)

    assert_not attachment.valid?
    assert_match %r{cannot be blank}, attachment.errors[:"attachment_data.file"].first
  end

  test "update with empty nested attachment data attributes still works" do
    attachment = create(:file_attachment)

    params = {
      "title" => "Filename",
      "attachment_data_attributes" => {
        "file_cache" => "", "to_replace_id" => attachment.attachment_data.id
      },
    }
    attachment.reload

    assert attachment.update(params), attachment.errors.full_messages.to_sentence
    assert_equal "Filename", attachment.title
  end

  test "filename changed returns true when updated with a file with a new name" do
    attachment = create(:file_attachment)

    assert_not attachment.filename_changed?
    attachment.attachment_data.file = {}
    assert attachment.filename_changed?
  end

  test "return media preview_url if all_asset_variants_uploaded?" do
    attachment = create(:csv_attachment, attachable: create(:edition))
    assert_equal Plek.asset_root + "/media/#{attachment.attachment_data.id}/sample.csv/preview", attachment.publishing_api_details_for_format[:preview_url]
  end

  test "#assets returns assets list if all_asset_variants_uploaded?" do
    attachment = create(:csv_attachment, attachable: create(:edition))

    assert_equal [{ "asset_manager_id": attachment.attachment_data.assets.first.asset_manager_id, "filename": attachment.attachment_data.assets.first.filename }], attachment.publishing_api_details_for_format[:assets]
  end
end
