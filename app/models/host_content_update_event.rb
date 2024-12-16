class HostContentUpdateEvent < Data.define(:author, :created_at, :content_id, :content_title)
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
      )
    end
  end

  private

  def self.get_user_for_uuid(uuid)
    User.find_by(uid: uuid)
  end
end
