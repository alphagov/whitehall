require "test_helper"

class SupportingPageAttachmentTest < ActiveSupport::TestCase
  test "destroys attachment when destroyed" do
    supporting_page_attachment = create(:supporting_page_attachment)
    attachment = supporting_page_attachment.attachment

    attachment.expects(:destroy)
    supporting_page_attachment.destroy
  end
end