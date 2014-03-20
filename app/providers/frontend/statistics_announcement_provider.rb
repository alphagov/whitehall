module Frontend
  class StatisticsAnnouncementProvider
    def self.search(search_params = {})
      results = source.advanced_search(prepare_search_params(search_params))
      CollectionPage.new(build_collection(results['results']), total: results['total'], page: search_params[:page], per_page: search_params[:per_page])
    end

    def self.find_by_slug(slug)
      publisher_announcement = ::StatisticsAnnouncement.find_by_slug(slug)
      if publisher_announcement.present?
        build_from_publisher_model(publisher_announcement)
      end
    end

  private
    def self.build_collection(release_announcement_hashes)
      Array(release_announcement_hashes).map { | release_announcement_hash | build_from_rummager_hash(release_announcement_hash) }
    end

    def self.build_from_rummager_hash(rummager_hash)
      Frontend::StatisticsAnnouncement.new({
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

    def self.build_from_publisher_model(model)
      Frontend::StatisticsAnnouncement.new({
        slug: model.slug,
        title: model.title,
        summary: model.summary,
        document_type: model.display_type,
        release_date: model.expected_release_date,
        release_date_text: model.display_release_date_override,
        organisations: [model.organisation],
        topics: [model.topic]
      })
    end

    def self.build_organisations(org_slugs)
      Organisation.find_all_by_slug(org_slugs)
    end

    def self.build_topics(topic_slugs)
      Topic.find_all_by_slug(topic_slugs)
    end

    def self.prepare_search_params(params)
      params = params.dup

      expected_release_timestamp_params = {
        from: params.delete(:from_date).try(:iso8601),
        to: params.delete(:to_date).try(:iso8601)
      }.delete_if {|k, v| v.blank? }
      params[:expected_release_timestamp] = expected_release_timestamp_params unless expected_release_timestamp_params.empty?

      params[:page] = params[:page].to_s
      params[:per_page] = params[:per_page].to_s
      params
    end

    def self.source
      if Rails.env.test? || (Rails.env.development? && ENV['RUMMAGER_HOST'].nil?)
        FakeRummagerApi
      else
        Whitehall.government_search_client
      end
    end


    class FakeRummagerApi
      def self.advanced_search(params = {})
        raise ArgumentError.new(":page and :per_page are required") unless params[:page].present? && params[:per_page].present?
        raise_unless_values_are_strings(params)

        scope = ::StatisticsAnnouncement.scoped.order("expected_release_date ASC")
        scope = scope.where("title LIKE('%#{params[:keywords]}%') or summary LIKE('%#{params[:keywords]}%')") if params[:keywords].present?
        if params[:organisations].present?
          organisation_ids = Organisation.find_all_by_slug(params[:organisations]).map &:id
          scope = scope.where(organisation_id: organisation_ids)
        end
        if params[:topics].present?
          topic_ids = Topic.find_all_by_slug(params[:topics]).map &:id
          scope = scope.where(topic_id: topic_ids)
        end
        if params[:expected_release_timestamp].present?
          scope = scope.where("expected_release_date > ?", params[:expected_release_timestamp][:from]) if params[:expected_release_timestamp][:from].present?
          scope = scope.where("expected_release_date < ?", params[:expected_release_timestamp][:to]) if params[:expected_release_timestamp][:to].present?
        end
        count = scope.count

        scope = scope.limit(params[:per_page]).offset((params[:page].to_i - 1) * params[:per_page].to_i)
        {
          'total' => count,
          'results' => scope.map { |announcement| announcement_to_rummager_hash(announcement) }
        }
      end

    private
      def self.raise_unless_values_are_strings(param_hash)
        param_hash.each do |key, value|
          if value.is_a? Hash
            raise_unless_values_are_strings(value)
          elsif !(value.is_a?(String) || value.is_a?(Array))
            raise ArgumentError.new("Search paramaters must be provided as strings, :#{key} was a #{value.class.name}")
          end
        end
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
          "search_format_types" => ["statistics_announcement"],
          "format" => "statistics_announcement"
        }
      end
    end
  end
end
