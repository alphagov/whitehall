module Import
  class HmctsCsvParser
    CSV_HEADERS = %i(
      publication_page_id
      artefact_code
      category
      artefact_file_name
      artefact_new_file_name
      artefact_title
      artefact_link
      artefact_url
      publication_type
      publication_title
      publication_summary
      publication_body
      published_before
      previous_publishing_date
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

    def self.publications(path)
      csv = CSV.read(path, headers: CSV_HEADERS)

      Enumerator.new do |yielder|
        page_id = nil
        publication_details = {}

        # Skip the header row
        csv[1..-1].each_with_index do |row, index|
          if row[:publication_page_id] == page_id
            publication_details[:attachments] << attachment_details(row)
          else
            yielder << publication_details unless page_id.nil?

            page_id = row[:publication_page_id]

            publication_details = {
              csv_row: index + 2, # Add 1 because Google Sheets is 1-indexed, and another 1 because we skipped the header row
              page_id: page_id,
              publication_type: row[:publication_type],
              title: row[:publication_title],
              summary: row[:publication_summary],
              body: row[:publication_body],
              # TODO: Handle multiple policy areas. We've asked HMCTS to semicolon-separate these
              policy_area: row[:policy_areas],
              attachments: [],
            }

            publication_details[:attachments] << attachment_details(row)
          end
        end

        yielder << publication_details
      end
    end

    def self.attachment_details(row)
      {
        title: row[:artefact_title],
        file_name: row[:artefact_file_name],
        url: row[:artefact_url],
      }
    end
  end
end
