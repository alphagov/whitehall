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
      access_limited
      schedule_publishing
      excluded_nations
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
          unless row[:publication_page_id] == page_id
            yielder << publication_details unless page_id.nil?

            page_id = row[:publication_page_id]

            publication_details = {

              page_id: page_id,
              publication_type: row[:publication_type],
              title: row[:publication_title],
              summary: row[:publication_summary],
              body: row[:publication_body],
              policy_areas: parse_multiple(row, :policy_areas),
              lead_organisations: parse_multiple(row, :lead_organisations),
              supporting_organisations: parse_multiple(row, :supporting_organisations),
              previous_publishing_date: row[:previous_publishing_date],
              access_limited: (row[:access_limited] || "").strip.casecmp("yes").zero?,
              excluded_nations: parse_multiple(row, :excluded_nations),
              attachments: [],
              csv_rows: [],
            }
          end

          publication_details[:attachments] << attachment_details(row)
          publication_details[:csv_rows] << index + 2 # Add 1 because Google Sheets is 1-indexed, and another 1 because we skipped the header row
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

    def self.parse_multiple(row, field)
      return [] unless row[field]

      row[field].split(";").map(&:strip)
    end
  end
end
