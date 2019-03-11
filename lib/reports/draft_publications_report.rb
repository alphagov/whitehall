module Reports
  class DraftPublicationsReport
    def initialize(start_date, end_date)
      @start_date = parse_date(start_date)
      @end_date = parse_date(end_date)
    end

    def report
      date_range = @start_date...@end_date
      draft_publications = get_draft_publications(date_range)
      organisations = Organisation.order(slug: :asc)

      path = "#{Rails.root}/tmp/number_of_draft_publications_by_organisation_#{@start_date}_to_#{@end_date}.csv".delete(' ')

      csv_headers = ["Lead publishing organisation", "Number of draft publications"]

      CSV.open(path, "wb", headers: csv_headers, write_headers: true) do |csv|
        puts "Searching for draft publications between #{start_date} and #{end_date}"

        organisations.find_each do |organisation|
          publications = draft_publications
            .where(edition_organisations: { lead: 1, organisation_id: organisation.id })

          csv << [
            organisation,
            publications.count
          ]
          puts "#{organisation.slug}: #{publications.count}"
        end
        puts "Report available at #{path}"
      end
    end

    private

    attr_reader :start_date, :end_date

    def parse_date(date)
      Time.zone.parse(date)
    end

    def get_draft_publications(date_range)
      Edition.include(Edition::Organisations)

      Edition.latest_edition
        .joins(:edition_organisations)
        .where(state: "draft")
        .where(type: "publication")
        .where(updated_at: date_range)
    end
  end
end
