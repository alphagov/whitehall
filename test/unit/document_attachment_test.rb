require 'test_helper'

class DocumentAttachmentTest < ActiveSupport::TestCase

  test "informs attachment when it is destroyed" do
    document_attachment = create(:document_attachment)
    document_attachment.attachment.expects(:destroy_if_unassociated)
    document_attachment.destroy
  end

end
