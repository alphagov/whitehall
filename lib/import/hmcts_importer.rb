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

        # TODO: Populate "published before" date
        # TODO: Set "published before" to true if there is a date
        # TODO: Populate policy
        # TODO: Populate supporting organisations
        # TODO: Populate excluded nations
        # TODO: Populate access limiting flag

        # TODO: Add attachments

        publication.save!
        puts "Created publication with ID #{publication.id}"
      end
    end

    def self.default_organisation
      @_default_organisation ||= Organisation.find_by(name: "Ministry of Justice")
    end
  end
end
