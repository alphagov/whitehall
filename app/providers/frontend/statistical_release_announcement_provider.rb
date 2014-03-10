module Frontend
  class StatisticalReleaseAnnouncementProvider
    def self.find_by(filter_params = {})
      release_announcement_hashes = source.advanced_search(filter_params)
      build_collection(release_announcement_hashes)
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
        expected_release_date: rummager_hash['expected_release_date'],
        display_release_date: rummager_hash['display_release_date'],
        organisations: Array(rummager_hash['organisations']).map {|org_hash| Frontend::OrganisationMetadata.new(name: org_hash['name'], slug: org_hash['slug']) },
        topics: Array(rummager_hash['topics']).map {|topic_hash| Frontend::TopicMetadata.new(name: topic_hash['name'], slug: topic_hash['slug']) }
      })
    end

    def self.source
      FakeRummagerApi
    end

    class FakeRummagerApi
      def self.advanced_search(params = {})
        scope = ::StatisticalReleaseAnnouncement.scoped.order("expected_release_date ASC")
        scope = scope.where("title LIKE('%#{params[:keywords]}%') or summary LIKE('%#{params[:keywords]}%')") if params[:keywords].present?
        if params[:from_date].present? && params[:from_date] > Time.zone.now
          from_date = params[:from_date]
        else
          from_date = Time.zone.now
        end
        scope = scope.where("expected_release_date > ?", from_date)
        scope = scope.where("expected_release_date < ?", params[:to_date]) if params[:to_date].present?
        scope.map { |announcement| announcement_to_rummager_hash(announcement) }
      end

      def self.announcement_to_rummager_hash(announcement)
        {
          "title" => announcement.title,
          "description" => announcement.summary,
          "slug" => announcement.slug,
          "expected_release_date" => announcement.expected_release_date,
          "display_release_date" => announcement.display_release_date_override,
          "organisations" => ([{ "name" => announcement.organisation.name, "slug" => announcement.organisation.slug }] if announcement.organisation.present?),
          "topics" => ([{ "name" => announcement.topic.name, "slug" => announcement.topic.slug }] if announcement.topic.present?),
          "display_type" => announcement.publication_type.singular_name
        }
      end
    end
  end
end
