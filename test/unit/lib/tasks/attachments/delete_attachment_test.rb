require "test_helper"
require "rake"

class DeleteAttachmentTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "#delete_attachment" do
    let(:task) { Rake::Task["delete_attachment"] }
    let(:content_id) { "e937f410-12fa-4166-bb0e-d5f5e47cbbfa" }
    teardown { task.reenable }

    it "raises an error if attachment does not exist" do
      ServiceListeners::AttachmentUpdater.expects(:call).never
      PublishingApiRedirectWorker.any_instance.expects(:perform).never

      out, _err = capture_io { task.invoke(content_id) }
      assert_equal "Unable to find any non-deleted attachments with content_id #{content_id}", out.strip
    end

    it "raises an error if edition associated with an attachment does not exist" do
      attachment = create(:html_attachment, content_id:)
      attachment.attachable.delete
      ServiceListeners::AttachmentUpdater.expects(:call).never
      PublishingApiRedirectWorker.any_instance.expects(:perform).never

      out, _err = capture_io { task.invoke(content_id) }
      assert_match(/Edition does not exist or edition is not superseded./, out.strip)
    end

    it "raises an error if edition associated with an attachment is not superseded" do
      create(:html_attachment, content_id:, attachable: create(:published_edition))
      ServiceListeners::AttachmentUpdater.expects(:call).never
      PublishingApiRedirectWorker.any_instance.expects(:perform).never

      out, _err = capture_io { task.invoke(content_id) }
      assert_match(/Edition does not exist or edition is not superseded./, out.strip)
    end

    it "raises an error if attachable associated with an attachment is not an edition" do
      create(:html_attachment, content_id:, attachable: create(:policy_group))
      ServiceListeners::AttachmentUpdater.expects(:call).never
      PublishingApiRedirectWorker.any_instance.expects(:perform).never

      out, _err = capture_io { task.invoke(content_id) }
      assert_match(/Edition does not exist or edition is not superseded./, out.strip)
    end

    it "removes attachment and translations associated content ID" do
      attachment = create(:html_attachment, content_id:, attachable: create(:superseded_edition))
      ServiceListeners::AttachmentUpdater.expects(:call).with(attachment_data: attachment.attachment_data)
      PublishingApiRedirectWorker.any_instance.expects(:perform).with(
        attachment.content_id,
        attachment.attachable.public_path,
        "en",
      )

      capture_io { task.invoke(content_id) }
      assert attachment.reload.deleted
    end
  end
end
