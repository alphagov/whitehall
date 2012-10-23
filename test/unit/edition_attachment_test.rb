require 'test_helper'

class EditionAttachmentTest < ActiveSupport::TestCase
  test "destroys attachment when destroyed" do
    edition_attachment = create(:edition_attachment)
    attachment = edition_attachment.attachment

    attachment.expects(:destroy)
    edition_attachment.destroy
  end
end
