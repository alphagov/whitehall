require 'test_helper'

class CorporateInformationPageAttachmentTest < ActiveSupport::TestCase
  test "destroys attachment when destroyed" do
    corporate_information_page_attachment = create(:corporate_information_page_attachment)
    attachment = corporate_information_page_attachment.attachment

    attachment.expects(:destroy)
    corporate_information_page_attachment.destroy
  end
end
