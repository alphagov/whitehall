class DataHygiene::DeletedDocumentRestorer
  def initialize(document_id, user_email)
    @document_id = document_id
    @user_email = user_email
  end

  def run!
    latest_edition = Edition.unscoped.where(document_id: @document_id).last

    unless latest_edition.deleted?
      raise RestoreDocumentError.latest_edition_not_deleted
    end

    user = User.where(email: @user_email).first

    if user.nil?
      raise RestoreDocumentError.user_not_found(@user_email)
    end

    latest_edition.create_draft(user, allow_creating_draft_from_deleted_edition: true)
  end

  class RestoreDocumentError < StandardError
    def self.latest_edition_not_deleted
      new("This document's latest edition is not deleted")
    end

    def self.user_not_found(user_email)
      new("This document doesn't exist for user with email #{user_email}")
    end
  end
end
