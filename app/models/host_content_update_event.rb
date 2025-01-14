class HostContentUpdateEvent < Data.define(:author, :created_at, :content_id, :content_title, :document_type)
  def self.all_for_date_window(document:, from:, to:)
    events = Services.publishing_api.get_events_for_content_id(document.content_id, {
      action: "HostContentUpdateJob",
      from:,
      to:,
    })

    events.map do |event|
      HostContentUpdateEvent.new(
        author: get_user_for_uuid(event["payload"]["source_block"]["updated_by_user_uid"]),
        created_at: Time.zone.parse(event["created_at"]),
        content_id: event["payload"]["source_block"]["content_id"],
        content_title: event["payload"]["source_block"]["title"],
        document_type: humanize_document_type(event["payload"]["source_block"]["document_type"]),
      )
    end
  end

  def is_for_newer_edition?(edition)
    edition.superseded? && created_at.after?(edition.superseded_at)
  end

  def is_for_current_edition?(edition)
    edition.published_at && created_at.after?(edition.published_at) && !is_for_newer_edition?(edition)
  end

  def is_for_older_edition?(edition)
    !is_for_newer_edition?(edition) && !is_for_current_edition?(edition)
  end

  def self.get_user_for_uuid(uuid)
    User.find_by(uid: uuid)
  end

  def self.humanize_document_type(document_type)
    document_type.delete_prefix("content_block_").humanize
  end
end
