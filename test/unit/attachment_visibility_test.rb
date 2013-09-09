require 'test_helper'

class AttachmentVisibilityTest < ActiveSupport::TestCase

  test '#visible? returns true when attachment data is associated with a published edition' do
    edition = create(:published_publication, :with_file_attachment_not_scanned)
    attachment_data = edition.attachments.first.attachment_data
    attachment_visibility = AttachmentVisibility.new(attachment_data,nil)

    assert attachment_visibility.visible?
    assert_nil attachment_visibility.unpublished_edition
  end

  test '#visible? returns false when edition is unpublished' do
    edition = create(:draft_publication, :with_file_attachment_not_scanned)
    attachment_data = edition.attachments.first.attachment_data
    attachment_visibility = AttachmentVisibility.new(attachment_data,nil)

    refute attachment_visibility.visible?
  end

  test '#visible? returns true when attachment is associated with a corporate info page' do
    info_page = create(:corporate_information_page, :with_alternative_format_provider)
    info_page.attachments << create(:file_attachment)
    attachment_data = info_page.attachments.first.attachment_data
    attachment_visibility = AttachmentVisibility.new(attachment_data,nil)

    assert attachment_visibility.visible?
  end

  test '#visible? returns true when attachment is associated with a response on a published consultation' do
    response = create(:consultation_with_outcome).outcome
    response.attachments << create(:file_attachment)
    attachment_data = response.attachments.first.attachment_data
    attachment_visibility = AttachmentVisibility.new(attachment_data,nil)

    assert attachment_visibility.visible?
  end

  test '#unpublished_edition returns the edition for an attachment associated with an unpublished edition' do
    unpublished_edition = create(:publication, :unpublished, :with_file_attachment)
    attachment_data = unpublished_edition.attachments.first.attachment_data
    attachment_visibility = AttachmentVisibility.new(attachment_data,nil)

    refute attachment_visibility.visible?
    assert_equal unpublished_edition, attachment_visibility.unpublished_edition
  end

  test '#unpublished_edition returns the edition, even if it is deleted' do
    unpublished_edition = create(:publication, :unpublished, :with_file_attachment)
    unpublished_edition.delete!
    attachment_data = unpublished_edition.attachments.first.attachment_data
    attachment_visibility = AttachmentVisibility.new(attachment_data, nil)

    refute attachment_visibility.visible?
    assert_equal unpublished_edition, attachment_visibility.unpublished_edition
  end
end
