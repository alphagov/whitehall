module Import
  class HmctsCsvParser
    CSV_HEADERS = %i(
      publication_page_id
      artefact_code
      category
      artefact_file_name
      artefact_type
      artefact_title
      artefact_link
      artefact_url
      publication_type
      publication_title
      publication_summary
      publication_body
      published_before
      has_images
      alternative_format_email
      policy
      policy_areas
      lead_organisations
      supporting_organisations
      excluded_nations
      access_limiting
      schedule_publishing
      attachment_accessible
      new_publication_url
      new_attachment_url
    ).freeze

    PUBLICATION_TYPE_SLUGS = {
      "Form" => "forms",
      "Guidance" => "guidance",
    }.freeze

    def self.publications(path)
      csv = CSV.read(path, headers: CSV_HEADERS)

      Enumerator.new do |yielder|
        page_id = nil
        publication_details = {}

        # Skip the header row
        csv[1..-1].each do |row|
          if row[:publication_page_id] == page_id

          else
            yielder << publication_details unless page_id.nil?

            publication_details = {
              publication_type: publication_type_slug(row[:publication_type]),
              title: row[:publication_title],
              summary: row[:publication_summary],
              body: row[:publication_body],
              # TODO: Handle multiple policy areas. Will they comma-separate these?
              policy_area: row[:policy_areas],
            }

            page_id = row[:publication_page_id]
          end
        end

        yielder << publication_details
      end
    end

    def self.publication_type_slug(name)
      PUBLICATION_TYPE_SLUGS[name] || raise("Unknown publication type '#{name}'")
    end
  end
end
