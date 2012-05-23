require 'test_helper'

class DocumentAttachmentTest < ActiveSupport::TestCase
  test "destroys attachment when no documents are associated" do
    document_attachment = create(:document_attachment)
    attachment = document_attachment.attachment
    other_document_attachment = create(:document_attachment, attachment: attachment)

    attachment.expects(:destroy).never
    document_attachment.destroy
  end

  test "does not destroy attachment when if more documents are associated" do
    document_attachment = create(:document_attachment)
    attachment = document_attachment.attachment

    attachment.expects(:destroy)
    document_attachment.destroy
  end
end
