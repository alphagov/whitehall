module Frontend
  class StatisticalReleaseAnnouncementProvider
    def self.search(filter_params = {})
      raise ArgumentError.new(":page and :per_page are required") unless filter_params[:page].present? && filter_params[:per_page].present?

      results = source.advanced_search(filter_params)
      CollectionPage.new(build_collection(results['results']), total: results['total'], page: filter_params[:page], per_page: filter_params[:per_page])
    end

  private
    def self.build_collection(release_announcement_hashes)
      Array(release_announcement_hashes).map { | release_announcement_hash | build_from_rummager_hash(release_announcement_hash) }
    end

    def self.build_from_rummager_hash(rummager_hash)
      Frontend::StatisticalReleaseAnnouncement.new({
        slug: rummager_hash['slug'],
        title: rummager_hash['title'],
        summary: rummager_hash['description'],
        document_type: rummager_hash['display_type'],
        release_date: rummager_hash['expected_release_timestamp'],
        release_date_text: rummager_hash['expected_release_text'],
        organisations: build_organisations(rummager_hash['organisations']),
        topics: build_topics(rummager_hash['topics'])
      })
    end

    def self.build_organisations(org_slugs)
      Organisation.find_all_by_slug(org_slugs)
    end

    def self.build_topics(topic_slugs)
      Topic.find_all_by_slug(topic_slugs)
    end

    def self.source
      FakeRummagerApi
    end

    class FakeRummagerApi
      def self.advanced_search(params = {})
        raise ArgumentError.new(":page and :per_page are required") unless params[:page].present? && params[:per_page].present?

        scope = ::StatisticalReleaseAnnouncement.scoped.order("expected_release_date ASC")
        scope = scope.where("title LIKE('%#{params[:keywords]}%') or summary LIKE('%#{params[:keywords]}%')") if params[:keywords].present?
        scope = scope.where("expected_release_date > ?", params[:from_date]) if params[:from_date].present?
        scope = scope.where("expected_release_date < ?", params[:to_date]) if params[:to_date].present?

        count = scope.count

        scope = scope.limit(params[:per_page]).offset((params[:page]-1) * params[:per_page])
        {
          'total' => count,
          'results' => scope.map { |announcement| announcement_to_rummager_hash(announcement) }
        }
      end

      def self.announcement_to_rummager_hash(announcement)
        {
          "title" => announcement.title,
          "description" => announcement.summary,
          "slug" => announcement.slug,
          "expected_release_timestamp" => announcement.expected_release_date.iso8601,
          "expected_release_text" => announcement.display_release_date_override || announcement.expected_release_date.to_s(:long),
          "organisations" => Array(announcement.organisation.try :slug),
          "topics" => Array(announcement.topic.try :slug),
          "display_type" => announcement.publication_type.singular_name,
          "search_format_types" => ["statistical_release_announcement"],
          "format" => "statistical_release_announcement"
        }
      end
    end
  end
end
