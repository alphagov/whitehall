require 'test_helper'

class NewAttachmentVisibilityTest < ActiveSupport::TestCase
  test "visible? returns false if attachment_data is nil?" do
    attachment_visibility = NewAttachmentVisibility.new(nil, User.new(id: 1))
    refute attachment_visibility.visible?
  end

  test "visible? returns false if the attachment_data only has a deleted attachment" do
    attachment_data = build(:attachment_data)
    attachment = build(:file_attachment)
    attachment.deleted = true
    attachment_data.attachments << attachment
    attachment_data.save
    attachment_visibility = NewAttachmentVisibility.new(attachment_data, User.new(id: 1))
    refute attachment_visibility.visible?
  end

  test "visible? returns true if the attachment_data has an undeleted attachment" do
    attachment_data = build(:attachment_data)
    attachment = build(:file_attachment)
    attachment_data.attachments << attachment
    attachment_data.save
    attachment_visibility = NewAttachmentVisibility.new(attachment_data, User.new(id: 1))
    assert attachment_visibility.visible?
  end

  test "visible? returns true if the attachment_data has an undeleted attachment on a visible edition" do
    publication = create(:published_publication, :with_file_attachment)
    attachment_data = publication.attachments.first.attachment_data
    attachment_visibility = NewAttachmentVisibility.new(attachment_data, nil)
    assert attachment_visibility.visible?
  end

  test "visible? returns false if the attachment_data only has a deleted attachment on a visible edition" do
    publication = create(:published_publication, :with_file_attachment)
    attachment_data = publication.attachments.first.attachment_data
    attachment = publication.attachments.last
    attachment.save
    attachment.destroy
    attachment_visibility = NewAttachmentVisibility.new(attachment_data, User.new(id: 1))
    refute attachment_visibility.visible?
  end

  test "visble? returns false if the visible edition has a deleted attachment but there is an undeleted on a previous edition" do
    first_publication = create(:draft_publication, :with_file_attachment)
    attachment_data = first_publication.attachments.first.attachment_data
    second_publication = create(:published_publication)
    second_publication.attachments = first_publication.attachments.map(&:deep_clone)
    second_publication.attachments.last.destroy
    attachment_visibility = NewAttachmentVisibility.new(attachment_data, User.new(id: 1))
    refute attachment_visibility.visible?
  end

  test "visible? returns true if the attachment data has an undeleted attachment on a visible edition that is accessible to the user" do
    publication = create(:published_publication, :with_file_attachment)
    attachment_data = publication.attachments.first.attachment_data
    attachment_visibility = NewAttachmentVisibility.new(attachment_data, User.new(id: 1))
    Edition.stubs(:accessible_to).returns(Edition.all)
    assert attachment_visibility.visible?
  end

  test "visible? returns false if the attachment data has an undeleted attachment on a visible edition that is not accesible to the user" do
    publication = create(:published_publication, :with_file_attachment)
    attachment_data = publication.attachments.first.attachment_data
    attachment_visibility = NewAttachmentVisibility.new(attachment_data, User.new(id: 1))
    Edition.stubs(:accessible_to).returns(Edition.where(id: ""))
    refute attachment_visibility.visible?
  end

  test "visible_edition returns nil if there are no related visible editions" do
    publication = create(:draft_publication, :with_file_attachment)
    attachment_data = publication.attachments.first.attachment_data
    attachment_visibility = NewAttachmentVisibility.new(attachment_data, User.new(id: 1))
    assert_nil attachment_visibility.visible_edition
  end

  test "visible_edition returns the edition if there are is one" do
    publication = create(:published_publication, :with_file_attachment)
    attachment_data = publication.attachments.first.attachment_data
    attachment_visibility = NewAttachmentVisibility.new(attachment_data, User.new(id: 1))
    assert_equal publication, attachment_visibility.visible_edition
  end

  test "visible_attachment returns nil if there is visible edition" do
    publication = create(:draft_publication, :with_file_attachment)
    attachment_data = publication.attachments.first.attachment_data
    attachment_visibility = NewAttachmentVisibility.new(attachment_data, User.new(id: 1))
    assert_nil attachment_visibility.visible_attachment
  end

  test "visible_attachment returns the attachment if there are is one" do
    first_publication = create(:draft_publication, :with_file_attachment)
    first_attachment = first_publication.attachments.last
    second_publication = create(:published_publication)
    second_publication.attachments = first_publication.attachments.map(&:deep_clone)
    second_attachment = second_publication.attachments.last
    first_attachment.destroy
    attachment_data = second_publication.attachments.first.attachment_data
    attachment_visibility = NewAttachmentVisibility.new(attachment_data, User.new(id: 1))
    assert_equal second_attachment, attachment_visibility.visible_attachment
  end
end
