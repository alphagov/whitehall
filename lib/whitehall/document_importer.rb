require "open-uri"
require "pdf-reader"
require "timecop"

class Whitehall::DocumentImporter
  def self.import!(data)
    edition = create_base_edition!(data)

    edition.document.update_columns(
      content_id: data["content_id"],
      slug: data["base_path"].split("/").last,
    )
    edition.document
  end

  def self.create_base_edition!(data)
    user = User.find_by(email: data["created_by"]) || Whitehall::DocumentImporter.robot_user
    AuditTrail.acting_as(user) do
      # Override time, otherwise "Document created" timestamp in sidebar reflects current date
      Timecop.travel(Time.zone.parse(data["first_published_at"])) do
        edition = StandardEdition.new(
          configurable_document_type: data["document_type"],
          created_at: data["created_at"],
          state: derived_state(data["state"]),
          title: data["title"],
          summary: data["summary"],
          block_content: {
            "body" => data["body"],
          },
          political: data["political"],
          government_id: data["government_id"],
          alternative_format_provider_id: Organisation.find_by(content_id: data["tags"]["primary_publishing_organisation"]).id,
        )
        edition.creator = user
        set_publish_timestamps(edition, data)
        edition.save!
        return edition
      end
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

  def self.set_publish_timestamps(edition, data)
    if Time.zone.parse(data["created_at"]) > Time.zone.parse(data["first_published_at"])
      edition.first_published_at = data["first_published_at"]
      edition.previously_published = true
    else
      edition.previously_published = false
    end
    edition.major_change_published_at = data["first_published_at"]
  end

  def self.robot_user
    User.find_by(name: "Scheduled Publishing Robot")
  end
end
