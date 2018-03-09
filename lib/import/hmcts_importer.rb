module Import
  class HmctsImporter
    PUBLICATION_TYPE_SLUGS = {
      "Form" => "forms",
      "Guidance" => "guidance",
    }.freeze

    def initialize(dry_run)
      @dry_run = dry_run
    end

    def import(csv_path)
      importer_user = User.find_by!(name: "Automatic Data Importer")
      raise "Could not find 'Automatic Data Importer' user" unless importer_user

      publication_ids = []

      HmctsCsvParser.publications(csv_path).each do |publication_data|
        begin
          publication = Publication.new
          publication.publication_type = PublicationType.find_by_slug(publication_type_slug(publication_data[:publication_type]))
          publication.title = publication_data[:title]
          publication.summary = publication_data[:summary]
          publication.body = publication_data[:body]
          publication.topics = publication_data[:policy_areas].map { |policy_area| Topic.find_by!(name: policy_area) }
          publication.lead_organisations = [default_organisation]
          publication.creator = importer_user
          publication.alternative_format_provider = hmcts_organisation
          publication.first_published_at = Date.parse(publication_data[:previous_publishing_date])
          publication.access_limited = publication_data[:access_limited]

          publication_data[:excluded_nations].each do |excluded_nation|
            nation = Nation.find_by_name!(excluded_nation)
            exclusion = NationInapplicability.new(nation: nation)
            publication.nation_inapplicabilities << exclusion
          end

          publication.validate!

          unless dry_run?
            publication.save!
            Whitehall.edition_services.draft_updater(publication).perform!
            publication_ids << publication.id
          end

          publication_data[:attachments].each do |attachment|
            create_attachment(attachment, publication)
          end
        rescue StandardError => error
          puts "Error for form #{publication_data[:page_id]} in rows #{publication_data[:csv_rows].join(', ')}"
          puts error
        end
      end

      puts "Created #{publication_ids.count} publications with edition IDs #{publication_ids.first} to #{publication_ids.last}" unless dry_run?
    end

    def default_organisation
      @_default_organisation ||= hmcts_organisation
    end

    def hmcts_organisation
      @_hmcts_organisation ||= Organisation.find_by!(name: "HM Courts & Tribunals Service")
    end

    def publication_type_slug(name)
      PUBLICATION_TYPE_SLUGS[name] || raise("Unknown publication type '#{name}'")
    end

    def create_attachment(attachment, publication)
      temp_file_path = "#{temp_directory}/#{attachment[:file_name]}"

      if dry_run?
        # Save as a txt because Whitehall attempts to generate a thumbnail
        # for pdf attachments, and will fail if the file is not a real PDF
        temp_file_path = temp_file_path + ".txt"
        File.open(temp_file_path, "w") { |file| file.write("Placeholder content") }
      else
        download_attachment(attachment[:url], temp_file_path)
      end

      attachment_data = AttachmentData.new(file: File.new(temp_file_path))
      file_attachment = FileAttachment.new(
        title: attachment[:title],
        attachment_data: attachment_data,
        attachable: publication,
      )
      file_attachment.validate!
      file_attachment.save! unless dry_run?
    end

    def download_attachment(hmcts_url, file_path)
      url = hmcts_url.sub(/^http\:/, "https:")
      response = Faraday.get(url)

      File.open(file_path, "wb") do |file|
        file.write(response.body)
      end
    end

    def temp_directory
      @_temp_directory ||= Dir.mktmpdir
    end

    def dry_run?
      @dry_run
    end
  end
end
