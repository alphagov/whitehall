require "mocha"
require "test_helper"

class AttachmentUpdaterTest < ActiveSupport::TestCase
  test "#update_attachment_data updates attachment_data" do
    attachment_data = create(:attachment_data, file: file_fixture("sample.rtf"))
    create(:file_attachment, title: "Title", attachment_data: attachment_data)

    AssetManagerAttachmentMetadataWorker.expects(:perform_async).with(attachment_data.id).once
    ServiceListeners::AttachmentUpdater.update_attachment_data(attachment_data)
  end

  test "#update_attachment_data doesn't update attachment_data if attachment is deleted" do
    attachment_data = create(:attachment_data, file: file_fixture("sample.rtf"))
    attachment = create(:file_attachment, title: "Title", attachment_data: attachment_data)
    attachment.update!(deleted: true)

    AssetManagerAttachmentMetadataWorker.expects(:perform_async).with(attachment_data.id).never
    ServiceListeners::AttachmentUpdater.update_attachment_data(attachment_data)
  end

  test "#update_all_attachment_data_for updates attachment data associated with an attachable's attachments" do
    attachment_data = create(:attachment_data, file: file_fixture("sample.rtf"))
    attachment = FileAttachment.new(title: "Title", attachment_data: attachment_data)
    edition = create(
      :publication,
      :with_file_attachment,
      attachments: [attachment],
    )

    AssetManagerAttachmentMetadataWorker.expects(:perform_async).with(attachment_data.id).once
    ServiceListeners::AttachmentUpdater.update_all_attachment_data_for(edition)
  end
end
