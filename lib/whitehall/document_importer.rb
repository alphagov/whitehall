require "open-uri"
require "pdf-reader"
require "timecop"

class Whitehall::DocumentImporter
  def self.import!(data)
    edition = create_base_edition!(data)

    AuditTrail.acting_as(robot_user) do
      EditorialRemark.create!(
        edition: edition,
        body: internal_history_summary(data["internal_history"]),
        author: robot_user,
        created_at: Time.zone.now,
        updated_at: Time.zone.now,
      )
    end

    save_attachments(data,edition)

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
            "body" => pre_process_body(data["body"]),
          },
          political: data["political"],
          government_id: data["government_id"],
          change_note: combined_change_notes(data["change_notes"]),
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

  def self.pre_process_body(body)
    # Content Publisher has embeds like `[Contact: c1f13fd8-9feb-4028-9323-7cb3383323b4]`.
    # Here we find-and-replace for Whitehall's equivalent: `[Contact:171]`
    body.gsub!(/\[Contact: ?(.+?)\]/) do |_match|
      id = Contact.find_by(content_id: ::Regexp.last_match(1)).id
      "[Contact:#{id}]"
    end
    body
  end

  def self.combined_change_notes(change_notes)
    return nil if change_notes.empty?

    change_notes.map { |cn|
      "#{Time.zone.parse(cn['public_timestamp']).strftime('%-d %B %Y')}: #{cn['note']}"
    }.join("; ")
  end

  def self.internal_history_summary(internal_history)
    return "No internal history available" if internal_history.empty?

    lines = [
      "Imported from Content Publisher on #{Time.zone.now.strftime('%-d %B %Y at %H:%M')}. Document history:<br>",
    ]
    internal_history.each do |entry|
      line = "#{entry['date']} #{entry['time']}: #{entry['entry_type'].to_s.humanize} by #{entry['user']}"
      line += ". Details: #{entry['entry_content']}" if entry["entry_content"].present?
      lines << "• #{line}"
    end

    lines.join("<br>")
  end

  def self.save_attachments(data, edition)
    data["attachments"].each do |attachment_hash|
      uploader_identifier = File.basename(attachment_hash["file_url"])
      response = URI.parse(attachment_hash["file_url"]).open
      attachment_data = AttachmentData.new(
        carrierwave_file: uploader_identifier,
        content_type: response.content_type,
        file_size: response.size,
        number_of_pages: response.content_type == "application/pdf" ? PDF::Reader.new(response).page_count : nil,
        created_at: attachment_hash["created_at"],
        updated_at: attachment_hash["created_at"],
      )

      # Temporarily disable callbacks that try to read the file to get its size and content type
      # since we don't have a local file, just the Asset Manager reference.
      attachment_data.skip_file_attribute_update = true
      attachment_data.save!(validate: false) # no local file, so have to skip validation
      Asset.create!(
        variant: "original",
        filename: File.basename(attachment_hash["file_url"]),
        asset_manager_id: attachment_hash["file_url"].match(%r{media/([^/]+)}).captures.first,
        assetable: attachment_data,
      )

      attachment = FileAttachment.create!(
        attachable: edition,
        title: attachment_hash["title"],
        attachment_data: attachment_data,
        accessible: false,
        isbn: "",
        unique_reference: "",
        command_paper_number: "",
        hoc_paper_number: "",
        parliamentary_session: "",
        unnumbered_command_paper: false,
        unnumbered_hoc_paper: false,
        created_at: attachment_hash["created_at"],
        updated_at: attachment_hash["created_at"],
      )
      edition.attachments << attachment
    end
  end

  def self.robot_user
    User.find_by(name: "Scheduled Publishing Robot")
  end
end
