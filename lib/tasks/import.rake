require "pp"
require "timecop"

namespace :import do
  desc "Import a news article exported via content-publisher#3311"
  task :news_article, %i[path_to_import_file] => :environment do |_, args|
    data = JSON.parse(File.read(args[:path_to_import_file]))
    user = User.find_by(email: data["created_by"]) || User.find_by(name: "Scheduled Publishing Robot")
    AuditTrail.acting_as(user) do
      # Override time, otherwise "Document created" timestamp in sidebar reflects current date
      Timecop.travel(Time.zone.parse(data["first_published_at"])) do
        # Roll back if we encounter any errors on the import
        ApplicationRecord.transaction do
          DocumentImporter.import!(data, user)
          # TODO: overwrite route
          # TODO: republish (minor update - to avoid sending email)
        end
      end
    end

    pp data
    puts "Imported to /government/admin/standard-editions/#{Edition.last.id}"
  rescue JSON::ParserError
    puts "Failed to parse JSON for #{args[:path_to_import_file]}"
  end
end

class DocumentImporter
  def self.import!(data, user)
    edition = StandardEdition.new(
      # TODO: change this to data["document_type"] once PressRelease has been migrated
      configurable_document_type: "news_story",
      created_at: data["created_at"],
      # TODO: honour 'previously published' field from the export (and specify the `first_published_at` field as `data["first_published_at"]` if `previously_published` is `true`)
      # But otherwise, treat all imports as NOT previously published - since we're also transferring over the creation dates etc. As as far as Whitehall is concerned, this is a new document.
      previously_published: false,
      title: data["title"],
      summary: data["summary"],
      block_content: {
        "body" => pre_process_body(data["body"]),
      },
      political: data["political"],
      # TODO: have we properly exported this? Find an example of a public changenote.
      change_note: "",
      # TODO: status should be overridden to published/withdrawn etc
      # TODO: we haven't preserved government info - have we? (`government_id`?).
      # TODO: we need to enable history mode support on config-driven news articles first.
      # TODO: `alternative_format_provider_id: 532` for attachments?
    )

    # Post edition-creation steps
    lead_image = nil
    data["images"].each do |image_hash|
      image = import_image_and_its_variants(image_hash, edition)
      edition.images << image
      lead_image = image if image_hash["lead_image"]
    end
    edition.block_content["image"] = lead_image&.image_data_id.to_s || ""
    edition.creator = user
    edition.save!

    edition.document.update_columns(
      content_id: data["content_id"],
      slug: data["base_path"].split("/").last,
    )
    edition.document
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
      # TODO: we ought to export the created/updated at times from CP too:
      # created_at: image_hash["created_at"],
      # updated_at: image_hash["updated_at"],
    )
  end

  def self.import_image_variant(variant, image_data)
    variant_mappings = {
      "high_resolution" => "original",
      "960" => "s960",
      "300" => "s300",
    }
    variant_name = variant_mappings[variant["variant"]]
    raise "Unknown variant: #{variant['variant']}" unless variant_name

    Asset.create!(
      variant: variant_name,
      filename: File.basename(variant["file_url"]),
      asset_manager_id: variant["file_url"].match(%r{media/([^/]+)}).captures.first,
      assetable: image_data,
    )
  end
end
