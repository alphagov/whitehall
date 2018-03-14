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
    attachment_data.visible_to?(user)
  end

  def unpublished_edition
    attachment_data.unpublished_edition
  end

  def visible_attachment
    attachment_data.visible_attachment_for(user)
  end

  def visible_attachable
    attachment_data.visible_attachable_for(user)
  end

  def visible_edition
    attachment_data.visible_edition_for(user)
  end

  def visible_consultation_response
    attachment_data.visible_attachable_for(user)
  end

  def visible_policy_group
    attachment_data.visible_attachable_for(user)
  end
end
