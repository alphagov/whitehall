require "open-uri"
require "pdf-reader"

class Whitehall::DocumentImporter
  def self.import!(data)
    edition = create_base_edition!(data)
    # Whitehall's in-house 'AuditTrail' is used to populate the timeline in
    # the sidebar, so we need to overwrite the created_at date.
    edition.most_recent_version.update!(created_at: data["created_at"])

    edition.document.update_columns(
      created_at: data["created_at"],
      content_id: data["content_id"],
      slug: data["base_path"].split("/").last,
    )
    edition.document
  end

  def self.create_base_edition!(data)
    user = User.find_by(email: data["created_by"]) || Whitehall::DocumentImporter.robot_user
    AuditTrail.acting_as(user) do
      edition = StandardEdition.new(
        configurable_document_type: data["document_type"],
        state: derived_state(data["state"]),
        title: data["title"],
        summary: data["summary"],
        block_content: {
          "body" => data["body"],
        },
        political: data["political"],
        government_id: Government.find_by(content_id: data["government_id"])&.id,
        alternative_format_provider_id: Organisation.find_by(content_id: data["tags"]["primary_publishing_organisation"]).id,
      )
      edition.creator = user
      set_publishing_metadata(edition, data)
      if data["state"] == "withdrawn"
        withdrawn = data["internal_history"].find { |h| h["entry_type"] == "withdrawn" }
        withdrawn_timestamp = Time.zone.parse("#{withdrawn['date']} #{withdrawn['time']}")
        unpublishing = Unpublishing.new(
          unpublishing_reason_id: UnpublishingReason::Withdrawn.id,
          explanation: withdrawn["entry_content"] || "Withdrawn document imported from Content Publisher",
          alternative_url: nil,
          created_at: withdrawn_timestamp,
          updated_at: withdrawn_timestamp,
          document_type: "StandardEdition",
          slug: data["base_path"].split("/").last,
          redirect: false,
          content_id: data["content_id"],
          unpublished_at: withdrawn_timestamp,
        )
        edition.unpublishing = unpublishing
      end
      edition.save!
      return edition
    end
  end

  def self.derived_state(state)
    case state
    when "published", "published_but_needs_2i"
      "published"
    when "withdrawn"
      "withdrawn"
    else
      raise "Unsupported state: #{state}"
    end
  end

  def self.set_publishing_metadata(edition, data)
    edition.created_at = data["created_at"]
    edition.first_published_at = data["first_published_at"]
    edition.previously_published = data["created_at"] > data["first_published_at"]

    # We're only importing a single 'flattened' edition
    # from Content Publisher. This doesn't play nicely with the
    # Edition model's `set_public_timestamp` callback, which checks
    #  if this is the "first published version" (defined in `Edition::Publishing`),
    # which is true if `published_major_version` is `nil` or `1`.
    # It would then set `public_timestamp` to `first_published_at`,
    # which is not the correct timestamp if there was a subsequent
    # major version.
    # By setting `published_major_version` to a minimum of `2`, the
    # `set_public_timestamp` falls back to `major_change_published_at`,
    # which we've set to match the latest public changenote timestamp
    # associated with the edition, which is the correct value.
    edition.published_major_version = 2
    edition.major_change_published_at = data["change_notes"].first["public_timestamp"]
  end

  def self.robot_user
    User.find_by(name: "Scheduled Publishing Robot")
  end
end
