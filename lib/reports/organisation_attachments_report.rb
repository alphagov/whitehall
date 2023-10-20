module Reports
  class OrganisationAttachmentsReport
    CSV_HEADERS = [
      "Attachment title",
      "Attachment path",
      "File type",
      "Content type",
      "Content URL",
      "Publication date",
      "Last amended date",
    ].freeze

    def initialize(organisation_slug)
      @organisation_slug = organisation_slug
    end

    def report
      path = Rails.root.join("tmp/#{@organisation_slug}-attachments_#{Time.zone.now.strftime('%d-%m-%Y_%H-%M')}.csv")

      CSV.open(path, "wb", headers: CSV_HEADERS, write_headers: true) do |csv|
        organisation_id = Organisation.where(slug: @organisation_slug, govuk_status: "live").limit(1).pick(:id)

        editions = get_editions_by_organisation(organisation_id)

        puts "Found #{editions.count} editions containing attachments with organisation '#{@organisation_slug}'"

        editions.each do |edition|
          edition.attachments.each do |attachment|

            csv << [
              attachment.title,
              attachment.url,
              attachment.content_type,
              edition.type,
              "https://www.gov.uk/government/publications/#{edition.slug}",
              edition.first_published_at,
              attachment.updated_at,
            ]
          end
          print(".")
        end
      end
      puts "Finished! Report available at #{path}"
    end

  private

    attr_reader :organisation_slug

    def get_editions_by_organisation(organisation_id)
      Edition.find_by_sql([
        "SELECT e.*
         FROM editions e
         JOIN edition_organisations eo ON eo.edition_id = e.id AND eo.organisation_id = ? AND eo.lead = TRUE
         WHERE e.state = 'published'
         AND e.state != 'deleted'
         AND EXISTS(
           SELECT a.id
           FROM attachments a
           WHERE a.attachable_type = 'Edition'
           AND a.attachable_id = e.id
           AND a.attachment_data_id IS NOT NULL
         )
         ORDER BY e.created_at DESC",
        organisation_id,
      ])
    end
  end
end
