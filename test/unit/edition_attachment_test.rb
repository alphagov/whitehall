require 'test_helper'

class EditionAttachmentTest < ActiveSupport::TestCase
  test "destroys attachment when no editions are associated" do
    edition_attachment = create(:edition_attachment)
    attachment = edition_attachment.attachment
    other_edition_attachment = create(:edition_attachment, attachment: attachment)

    attachment.expects(:destroy).never
    edition_attachment.destroy
  end

  test "does not destroy attachment when if more editions are associated" do
    edition_attachment = create(:edition_attachment)
    attachment = edition_attachment.attachment

    attachment.expects(:destroy)
    edition_attachment.destroy
  end
end
