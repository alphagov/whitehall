require "mocha"
require "test_helper"

class AttachmentUpdaterTest < ActiveSupport::TestCase
  test "#call updates attachment_data that is passed directly" do
    attachment_data = build(:attachment_data, file: file_fixture("sample.rtf"))

    AssetManagerAttachmentMetadataWorker.expects(:perform_async).with(attachment_data.id).once
    ServiceListeners::AttachmentUpdater.call(attachment_data: attachment_data)
  end

  test "#call updates attachment data associated with an attachable's attachments" do
    attachment_data = build(:attachment_data, file: file_fixture("sample.rtf"))
    attachment = FileAttachment.new(title: "Title", attachment_data: attachment_data)
    edition = create(
      :publication,
      :with_file_attachment,
      attachments: [attachment],
    )

    AssetManagerAttachmentMetadataWorker.expects(:perform_async).with(attachment_data.id).once
    ServiceListeners::AttachmentUpdater.call(attachable: edition)
  end
end
