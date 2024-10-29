require "google/cloud/bigquery"
require "googleauth"

module ContentBlockManager
  class PageViewsService
    SQL = <<~SQL.freeze
      SELECT cleaned_page_location,
      COUNT (DISTINCT ga_sessionid) as unique_pageviews FROM
      (
        SELECT cleaned_page_location, ga_sessionid
        FROM `ga4-analytics-352613.flattened_dataset.partitioned_flattened_events`
        WHERE event_name = "page_view"
        AND cleaned_page_location IN UNNEST(@paths)
        AND event_date BETWEEN @start_date AND @end_date
      )
      GROUP BY cleaned_page_location
    SQL
    SCOPE = ["https://www.googleapis.com/auth/bigquery"].freeze

    attr_reader :paths, :start_date, :end_date

    def initialize(paths:)
      @paths = paths
      @end_date = Time.zone.today
      @start_date = @end_date - 30.days
    end

    def call
      results.map do |row|
        PageView.new(path: row[:cleaned_page_location], page_views: row[:unique_pageviews])
      end
    end

  private

    def results
      @results ||= bigquery.query SQL, params: { paths:, start_date: start_date.iso8601, end_date: end_date.iso8601 }
    end

    def bigquery
      @bigquery ||= Google::Cloud::Bigquery.new(
        project_id: ENV["BIGQUERY_PROJECT_ID"],
        credentials: Google::Auth::ServiceAccountCredentials.make_creds(
          json_key_io: StringIO.new(credentials.to_json),
          scope: SCOPE,
        ),
      )
    end

    def credentials
      {
        "client_email" => ENV["BIGQUERY_CLIENT_EMAIL"],
        "private_key" => ENV["BIGQUERY_PRIVATE_KEY"],
      }
    end
  end
end
