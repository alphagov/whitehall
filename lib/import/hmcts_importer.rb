module Import
  class HmctsImporter
    TITLE_MAX_LENGTH = 255

    def initialize(dry_run)
      @dry_run = dry_run
    end

    def import(csv_path)
      importer_user = User.find_by!(name: "Automatic Data Importer")
      raise "Could not find 'Automatic Data Importer' user" unless importer_user

      imported_publications = []

      HmctsCsvParser.publications(csv_path).each do |publication_data|
        puts "Importing form #{publication_data[:page_id]} from rows #{publication_data[:csv_rows].join(', ')}"

        imported_details = {}
        imported_details[:csv_rows] = publication_data[:csv_rows].join(', ')
        imported_details[:form_id] = publication_data[:page_id]

        begin
          publication = Publication.new
          publication.publication_type = default_publication_type
          publication.title = format_title(publication_data[:title])
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
            imported_details[:publication_id] = publication.id
            imported_details[:whitehall_url] = Whitehall.url_maker.admin_edition_url(publication)
            imported_details[:public_url] = Whitehall.url_maker.public_document_url(publication)
          end

          imported_details[:document_title_truncated] = title_too_long?(publication_data[:title])

          imported_attachments = []
          publication_data[:attachments].each do |attachment|
            imported_attachments << create_attachment(attachment, publication)
          end

          imported_details[:attachments_with_truncated_titles] = imported_attachments
            .select { |a| a[:title_truncated] }
            .map { |a| a[:file_name] }
            .join(", ")

          imported_details[:succeeded] = true
        rescue StandardError => error
          puts "Error for form #{publication_data[:page_id]} in rows #{publication_data[:csv_rows].join(', ')}"
          puts error

          imported_details[:succeeded] = false
          imported_details[:error] = error.message
        ensure
          imported_publications << imported_details
        end

        # Prevent the HMCTS import from blocking other publishing events
        wait_for_queue_to_drain
      end

      unless dry_run?
        puts "Created #{imported_publications.count} publications with edition IDs " +
          "#{imported_publications.first[:publication_id]} to #{imported_publications.last[:publication_id]}"
      end

      csv_path = "/tmp/hmcts_import_#{Time.new}.csv"
      CSV.open(csv_path, "w") do |csv|
        csv << [
          "page ID",
          "original CSV rows",
          "publication whitehall ID",
          "whitehall publisher URL",
          "public URL (once published)",
          "import succeeded?",
          "document title truncated?",
          "attachments with truncated titles",
          "import error",
        ]

        imported_publications.each do |publication|
          csv << [
            publication[:form_id],
            publication[:csv_rows],
            publication[:publication_id],
            publication[:whitehall_url],
            publication[:public_url],
            publication[:succeeded],
            publication[:document_title_truncated],
            publication[:attachments_with_truncated_titles],
            publication[:error],
          ]
        end
      end

      puts "Wrote output to #{csv_path}"
    end

    def default_organisation
      @_default_organisation ||= hmcts_organisation
    end

    def hmcts_organisation
      @_hmcts_organisation ||= Organisation.find_by!(name: "HM Courts & Tribunals Service")
    end

    def default_publication_type
      @_publication_type ||= PublicationType.find_by_slug("forms")
    end

    def format_title(title)
      return nil unless title
      title.slice(0, TITLE_MAX_LENGTH)
    end

    def title_too_long?(title)
      return false unless title
      title.length > TITLE_MAX_LENGTH
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
        title: format_title(attachment[:title]),
        attachment_data: attachment_data,
        attachable: publication,
      )
      file_attachment.validate!
      file_attachment.save! unless dry_run?

      {
        file_name: attachment[:file_name],
        title_truncated: title_too_long?(attachment[:title]),
      }
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

    def wait_for_queue_to_drain
      default_queue_size = Sidekiq::Queue.new("default").size
      publishing_queue_size = Sidekiq::Queue.new("publishing_api").size

      while default_queue_size.positive? || publishing_queue_size.positive? do
        puts "Default queue: #{default_queue_size}, publishing queue: #{publishing_queue_size}. Waiting until queues are clear."
        sleep(5)

        default_queue_size = Sidekiq::Queue.new("default").size
        publishing_queue_size = Sidekiq::Queue.new("publishing_api").size
      end
    end
  end
end
