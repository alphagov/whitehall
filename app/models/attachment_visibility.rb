# Utility class used to identify the publically visible Attachments and
# Attachable models that are associated with a given AttachmentData file.
#
# This class exists because of the way attachments are currently routed and
# served using the file path to the attachment file, e.g.
#
# /government/uploads/system/uploads/attachment_data/file/123/file.csv
#
# Given an AttachmentData (identified by the ID in the above URL), this class
# will identify the thing the file is associated with by following back up the
# chain.
#
# Attachments are served like this because in the early days, files were served
# directly by the webserver, bypassing the application entirely. Later, the app
# was updated to handle these URLs so that we could do things like  show an
# appropriate response if a file was being virus scanned, or redirect when it
# had been replaced by another version.
#
# In an ideal world, attachments would be served with a sensible routing
# structure that included the attachable thing in the path, e.g.
#
# /government/publications/slug-for-pub/attachments/file.csv
#
# or
#
# /government/publications/slug-for-pub/attachments/:id/file.csv
#
# This would friendlier for users, and would also greatly simplify the
# attachment serving code, as the attachable model could be easily identified.
#
class AttachmentVisibility
  attr_reader :attachment_data, :user

  def initialize(attachment_data, user)
    @attachment_data = attachment_data
    @user = user
  end

  def visible?
    visible_edition? || visible_corporate_information_page? || visible_policy_group? || visible_consultation_response?
  end

  def unpublished_edition
    if unpublishing = Unpublishing.where(edition_id: edition_ids).first
      Edition.unscoped.find(unpublishing.edition_id)
    end
  end

  def visible_attachment
    if visible_attachable
      (visible_attachable.attachments & attachment_data.attachments).first
    end
  end

  def visible_attachable
    visible_edition || visible_consultation_response || visible_corporate_information_page || visible_policy_group
  end

  def visible_edition
    visible_edition_scope.last
  end

  def visible_consultation_response
    if visible_consultation_response?
      Response.where(edition_id: consultation_ids).last
    end
  end

  def visible_corporate_information_page
    visible_corporate_information_page_scope.last
  end

  def visible_policy_group
    visible_policy_group_scope.last
  end

  private

  def id
    attachment_data.id
  end

  def visible_edition?
    visible_edition_scope.exists?
  end

  def visible_corporate_information_page?
    visible_corporate_information_page_scope.exists?
  end

  def visible_policy_group?
    visible_policy_group_scope.exists?
  end

  def visible_consultation_response?
    visible_consultation_scope.exists?
  end

  def visible_edition_scope
    if user
      Edition.accessible_to(user).where(id: edition_ids)
    else
      Edition.publicly_visible.where(id: edition_ids)
    end
  end

  def visible_consultation_scope
    if user
      Edition.accessible_to(user).where(id: consultation_ids)
    else
      Edition.publicly_visible.where(id: consultation_ids)
    end
  end

  def visible_corporate_information_page_scope
    CorporateInformationPage.joins(:attachments).where(attachments: { attachment_data_id: id })
  end

  def visible_policy_group_scope
    PolicyAdvisoryGroup.joins(:attachments).where(attachments: { attachment_data_id: id })
  end

  def consultation_ids
    @consultation_ids ||= Response.joins(:attachments).where(attachments: { attachment_data_id: id }).pluck(:edition_id)
  end

  def edition_ids
    @edition_ids ||= Attachment.where(attachment_data_id: id).where(attachable_type: 'Edition').pluck(:attachable_id)
  end
end
