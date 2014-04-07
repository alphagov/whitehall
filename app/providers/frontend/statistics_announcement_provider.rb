module Frontend
  class StatisticsAnnouncementProvider
    def self.search(search_params = {})
      results = Whitehall.statistics_announcement_search_client.advanced_search(prepare_search_params(search_params))
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
        release_date: rummager_hash['release_timestamp'],
        display_date: rummager_hash['metadata']['display_date'],
        release_date_confirmed: rummager_hash['metadata']['confirmed'],
        release_date_change_note: rummager_hash['metadata']['change_note'],
        previous_display_date: rummager_hash['metadata']['previous_display_date'],
        organisations: build_organisations(rummager_hash['organisations']),
        topics: build_topics(rummager_hash['topics'])
      })
    end

    def self.build_from_publisher_model(model)
      Frontend::StatisticsAnnouncement.new({
        slug: model.slug,
        title: model.title,
        summary: model.summary,
        publication: model.publication,
        document_type: model.display_type,
        release_date: model.current_release_date.release_date,
        display_date: model.current_release_date.display_date,
        release_date_confirmed: model.current_release_date.confirmed,
        release_date_change_note: model.current_release_date.change_note,
        previous_display_date: model.previous_display_date,
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

      release_timestamp_params = {
        from: params.delete(:from_date).try(:iso8601),
        to: params.delete(:to_date).try(:iso8601)
      }.delete_if {|k, v| v.blank? }
      params[:release_timestamp] = release_timestamp_params unless release_timestamp_params.empty?

      params[:page] = params[:page].to_s
      params[:per_page] = params[:per_page].to_s

      params[:format] = "statistics_announcement"

      params
    end
  end
end
