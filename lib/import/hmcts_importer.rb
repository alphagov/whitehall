module Import
  class HmctsImporter
    def self.import(csv_path)
      importer_user = User.find_by(name: "Automatic Data Importer")
      raise "Could not find 'Automatic Data Importer' user" unless importer_user

      HmctsCsvParser.publications(csv_path).each do |publication_data|
        puts publication_data

        publication = Publication.new
        publication.publication_type = PublicationType.find_by_slug(publication_data[:publication_type])
        publication.title = publication_data[:title]
        publication.summary = publication_data[:summary]
        publication.body = publication_data[:body]
        # TODO: Handle multiple policy areas
        publication.topics = [Topic.find_by(name: publication_data[:policy_area])]
        # TODO: Get from spreadsheet once it is always populated
        # TODO: Handle multiple lead organisations
        publication.lead_organisations = [default_organisation]
        publication.creator = importer_user
        # TODO: Should be HMCTS? Or another org with the email address provided in the CSV.
        publication.alternative_format_provider = default_organisation

        # TODO: Populate "published before" date
        # TODO: Set "published before" to true if there is a date
        # TODO: Populate policy
        # TODO: Populate supporting organisations
        # TODO: Populate excluded nations
        # TODO: Populate access limiting flag

        publication.save!
        puts "Created publication with ID #{publication.id}"

        publication_data[:attachments].each do |attachment|
          create_attachment(attachment, publication)
        end
      end
    end

    def self.default_organisation
      @_default_organisation ||= Organisation.find_by(name: "Ministry of Justice")
    end

    def self.create_attachment(attachment, publication)
      temp_file_path = "#{temp_directory}/#{attachment[:file_name]}"
      download_attachment(attachment[:url], temp_file_path)

      attachment_data = AttachmentData.new(file: File.new(temp_file_path))
      file_attachment = FileAttachment.new(
        title: attachment[:title],
        attachment_data: attachment_data,
        attachable: publication,
      )
      file_attachment.save!

      puts "Added attachment #{temp_file_path}"
    end

    def self.download_attachment(hmcts_url, file_path)
      url = hmcts_url.sub(/^http\:/, "https:")
      response = Faraday.get(url)

      File.open(file_path, "wb") do |file|
        file.write(response.body)
      end
    end

    def temp_directory
      @_temp_directory ||= Dir.mktmpdir
    end
  end
end
