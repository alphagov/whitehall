require "open-uri"
require "pdf-reader"

class Whitehall::DocumentImporter
  def self.import!(data)
    edition = create_base_edition!(data)
    # Whitehall's in-house 'AuditTrail' is used to populate the timeline in
    # the sidebar, so we need to overwrite the created_at date.
    edition.most_recent_version.update!(created_at: data["created_at"])

    AuditTrail.acting_as(robot_user) do
      EditorialRemark.create!(
        edition: edition,
        body: internal_history_summary(data["internal_history"]),
        author: robot_user,
        created_at: Time.zone.now,
        updated_at: Time.zone.now,
      )
    end

    save_attachments(data, edition)
    save_images(data, edition)

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
          "body" => pre_process_body(data["body"]),
        },
        political: data["political"],
        government_id: Government.find_by(content_id: data["government_id"])&.id,
        change_note: combined_change_notes(data["change_notes"]),
        lead_organisations: Organisation.where(content_id: data["tags"]["primary_publishing_organisation"]),
        supporting_organisations: Organisation.where(content_id: data["tags"]["organisations"]),
        topical_events: TopicalEvent.where(content_id: data["tags"]["topical_events"]),
        world_locations: WorldLocation.where(content_id: data["tags"]["world_locations"]),
        role_appointments: RoleAppointment.where(content_id: data["tags"]["role_appointments"]),
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

  def self.pre_process_body(body)
    # Content Publisher has embeds like `[Contact: c1f13fd8-9feb-4028-9323-7cb3383323b4]`.
    # Here we find-and-replace for Whitehall's equivalent: `[Contact:171]`
    body.gsub!(/\[Contact: ?(.+?)\]/) do |_match|
      contact = Contact.find_by(content_id: ::Regexp.last_match(1))
      contact ? "[Contact:#{contact.id}]" : ""
    end

    # Process footnotes:
    # 1) Collect single-line footnote definitions: `[^key]: text...`
    footnote_defs = {}
    body.scan(/^\[\^([^\]]+)\]:\s*(.+)\s*$/).each do |key, defn|
      footnote_defs[key] = defn.strip
    end

    # 2) Remove the footnote definition lines BEFORE replacing references
    body.gsub!(/^\[\^[^\]]+\]:.*\n?/, "")

    # 3) Replace inline references `[^key]` with ` (definition)`
    body.gsub!(/\[\^([^\]]+)\]/) do
      key = Regexp.last_match(1)
      defn = footnote_defs[key]
      defn ? " (#{defn})" : "" # drop unknown refs
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
    lines = [
      "Imported from Content Publisher. Document history:<br>",
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
      )
      edition.attachments << attachment
    end
  end

  def self.save_images(data, edition)
    lead_image = nil
    data["images"].each do |image_hash|
      image = import_image_and_its_variants(image_hash, edition)
      edition.images << image
      lead_image = image if image_hash["lead_image"]
    end

    if lead_image
      new_block_content = edition.block_content.to_h.merge("image" => lead_image.image_data_id.to_s)
      # avoiding calling `edition.save!(validate: false)` here as it would cause an unnecessary entry in the internal change history
      edition.translation.update!(block_content: new_block_content)
    end
  end

  def self.import_image_and_its_variants(image_hash, edition)
    original_variant = image_hash["variants"].find { |v| v["variant"] == "high_resolution" }
    uploader_identifier = File.basename(original_variant["file_url"])
    image_data = ImageData.new(
      image_kind: "default",
      carrierwave_image: uploader_identifier,
    )
    image_data.save!(validate: false) # no local file, so have to skip validation
    image_hash["variants"].each do |variant|
      import_image_variant(variant, image_data)
    end
    # Content Publisher exports a caption and a credit, but there is no credit in Whitehall.
    # We'll append the credit onto the caption as follows:
    # `caption` => "Foo"
    # `credit` => "Bar"
    # result => "Foo. Credit: Bar"
    caption_parts = [
      image_hash["caption"].presence,
      image_hash["credit"].blank? ? nil : "Credit: #{image_hash['credit']}",
    ].compact
    caption = caption_parts.join(". ")
    Image.create!(
      alt_text: image_hash["alt_text"],
      caption: caption,
      edition: edition,
      image_data: image_data,
      created_at: image_hash["created_at"],
    )
  end

  def self.import_image_variant(variant, image_data)
    variant_mappings = {
      "high_resolution" => %w[original],
      "960" => %w[s960 s712 s630 s465],
      "300" => %w[s300 s216],
    }
    variant_names = variant_mappings[variant["variant"]]
    raise "Unknown variant: #{variant['variant']}" unless variant_names

    variant_names.each do |variant_name|
      Asset.create!(
        variant: variant_name,
        filename: File.basename(variant["file_url"]),
        asset_manager_id: variant["file_url"].match(%r{media/([^/]+)}).captures.first,
        assetable: image_data,
      )
    end
  end

  def self.robot_user
    User.find_by(name: "Scheduled Publishing Robot")
  end
end
