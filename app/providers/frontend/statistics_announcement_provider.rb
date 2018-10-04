module Frontend
  class StatisticsAnnouncementProvider
    class << self
      def search(search_params = {})
        results = Whitehall.statistics_announcement_search_client.advanced_search(prepare_search_params(search_params))
        CollectionPage.new(build_collection(results['results']), total: results['total'], page: search_params[:page], per_page: search_params[:per_page])
      end

    private

      def build_collection(release_announcement_hashes)
        Array(release_announcement_hashes).map { |release_announcement_hash| build_from_rummager_hash(release_announcement_hash) }
      end

      def build_from_rummager_hash(rummager_hash)
        Frontend::StatisticsAnnouncement.new(
          slug: rummager_hash['slug'],
          title: rummager_hash['title'],
          summary: rummager_hash['description'],
          document_type: rummager_hash['display_type'],
          release_date: rummager_hash['release_timestamp'],
          display_date: rummager_hash['metadata']['display_date'],
          release_date_confirmed: rummager_hash['metadata']['confirmed'],
          release_date_change_note: rummager_hash['metadata']['change_note'],
          previous_display_date: rummager_hash['metadata']['previous_display_date'],
          organisations: build_organisations(rummager_hash['organisations']),
          state: rummager_hash['statistics_announcement_state'],
          cancellation_reason: rummager_hash['metadata']['cancellation_reason'],
          cancellation_date: rummager_hash['metadata']['cancelled_at']
        )
      end

      def build_organisations(org_slugs)
        Organisation.where(slug: org_slugs)
      end

      def prepare_search_params(params)
        params = params.dup

        params[:release_timestamp] = {
          from: (params.delete(:from_date) || Date.today).try(:iso8601),
          to: params.delete(:to_date).try(:iso8601)
        }.delete_if { |_k, v| v.blank? }

        params[:page] = params[:page].to_s
        params[:per_page] = params[:per_page].to_s

        params[:format] = "statistics_announcement"
        params[:order] = { release_timestamp: "asc" }

        params
      end
    end
  end
end
