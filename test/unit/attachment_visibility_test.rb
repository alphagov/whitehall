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
    info_page = create(:corporate_information_page, :with_alternative_format_provider, attachments: [
      build(:file_attachment)
    ])
    attachment_data = info_page.attachments.first.attachment_data
    attachment_visibility = AttachmentVisibility.new(attachment_data,nil)

    assert attachment_visibility.visible?
  end

  test '#visible? returns true when attachment is associated with a response on a published consultation' do
    response = create(:consultation_with_outcome).outcome
    response.attachments << build(:file_attachment)
    attachment_data = response.attachments.first.attachment_data
    attachment_visibility = AttachmentVisibility.new(attachment_data,nil)

    assert attachment_visibility.visible?
  end

  test '#visible_edition returns a published edition that the attachment is assigned to' do
    edition = create(:published_publication, :with_file_attachment)
    attachment_data = edition.attachments.first.attachment_data
    attachment_visibility = AttachmentVisibility.new(attachment_data, nil)

    assert_equal edition, attachment_visibility.visible_edition
  end

  test '#visible_edition returns an archived edition that the attachment is assigned to' do
    edition = create(:publication, :archived, :with_file_attachment)
    attachment_data = edition.attachments.first.attachment_data
    attachment_visibility = AttachmentVisibility.new(attachment_data, nil)

    assert_equal edition, attachment_visibility.visible_edition
  end

  test '#visible_consultation_response a published response that the attachment is associated with' do
    response   = create(:consultation_with_outcome).outcome
    response.attachments << attachment = build(:file_attachment)
    attachment_visibility = AttachmentVisibility.new(attachment.attachment_data, nil)

    assert_equal response, attachment_visibility.visible_consultation_response
  end

  test '#visible_consultation_response returns nil if the attachment is not associated with a response on a published consultation' do
    response = create(:consultation_with_outcome, :draft).outcome
    response.attachments << attachment = build(:file_attachment)
    attachment_visibility = AttachmentVisibility.new(attachment.attachment_data, nil)

    assert_equal :draft, response.consultation.current_state

    assert_nil attachment_visibility.visible_consultation_response
  end

  test '#visible_consultation_response returns a draft response if it is accessible to the provided user' do
    user = create(:policy_writer)

    response = create(:consultation_with_outcome, :draft).outcome
    response.attachments << attachment = build(:file_attachment)
    attachment_visibility = AttachmentVisibility.new(attachment.attachment_data, user)

    assert_equal :draft, response.consultation.current_state

    assert_equal response, attachment_visibility.visible_consultation_response
  end

  test '#visible_edition returns nil if the attachment is associated with a non-published edition' do
    edition = create(:draft_publication, :with_file_attachment)
    attachment_data = edition.attachments.first.attachment_data
    attachment_visibility = AttachmentVisibility.new(attachment_data, nil)

    assert_nil attachment_visibility.visible_edition
  end

  test '#visible_edition will return a draft edition if it is accessible to the provided user' do
    user = create(:policy_writer)
    edition = create(:draft_publication, :with_file_attachment)
    attachment_data = edition.attachments.first.attachment_data
    attachment_visibility = AttachmentVisibility.new(attachment_data, user)

    assert_equal edition, attachment_visibility.visible_edition
  end

  test '#visible_edition returns nil if the attachment is associated with a non-Edition' do
    info_page = create(:corporate_information_page, :with_alternative_format_provider, attachments: [
      build(:file_attachment)
    ])
    attachment_visibility = AttachmentVisibility.new(info_page.attachments.first.attachment_data, nil)

    assert_nil attachment_visibility.visible_edition
  end

  test '#visible_attachment returns the attachment associated with a published edition' do
    edition               = create(:published_publication, :with_file_attachment)
    new_draft             = edition.create_draft(create(:policy_writer))
    attachment            = edition.attachments.first
    attachment_visibility = AttachmentVisibility.new(attachment.attachment_data, nil)

    assert_equal attachment, attachment_visibility.visible_attachment
  end

  test '#visible_attachment returns nil if the attachment_data is not associated with a publically visible attachment' do
    edition               = create(:draft_publication, :with_file_attachment)
    attachment            = edition.attachments.first
    attachment_visibility = AttachmentVisibility.new(attachment.attachment_data, nil)

    assert_nil attachment_visibility.visible_attachment
  end

  test '#visible_attachment returns the attachment associated with the response of the published consultation' do
    response              = create(:consultation_with_outcome).outcome
    response.attachments << attachment = build(:file_attachment)
    attachment_visibility = AttachmentVisibility.new(attachment.attachment_data,nil)

    assert_equal attachment, attachment_visibility.visible_attachment
  end

  test '#visible_attachment returns the attachment associated with a corporate information page' do
    info_page  = create(:corporate_information_page, :with_alternative_format_provider, attachments: [
      attachment = build(:file_attachment)
    ])
    attachment_visibility = AttachmentVisibility.new(attachment.attachment_data,nil)

    assert_equal attachment, attachment_visibility.visible_attachment
  end

  test '#visible_attachment returns the attachment associated with a policy group' do
    advisory_group  = create(:policy_advisory_group, attachments: [
      attachment = build(:file_attachment)
    ])
    attachment_visibility = AttachmentVisibility.new(attachment.attachment_data,nil)

    assert_equal attachment, attachment_visibility.visible_attachment
  end

  test '#unpublished_edition returns the edition for an attachment associated with an unpublished edition' do
    unpublished_edition = create(:publication, :unpublished, :with_file_attachment)
    attachment_data = unpublished_edition.attachments.first.attachment_data
    attachment_visibility = AttachmentVisibility.new(attachment_data,nil)

    refute attachment_visibility.visible?
    assert_equal unpublished_edition, attachment_visibility.unpublished_edition
  end

  test '#unpublished_edition returns the edition, even if it is deleted' do
    deleted_edition = create(:deleted_publication, :with_file_attachment)
    create(:unpublishing, edition: deleted_edition)
    attachment_data = deleted_edition.attachments.first.attachment_data
    attachment_visibility = AttachmentVisibility.new(attachment_data, nil)

    refute attachment_visibility.visible?
    assert_equal deleted_edition, attachment_visibility.unpublished_edition
  end
end
