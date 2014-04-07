module DevelopmentModeStubs
  class FakeRummagerApiForStatisticsAnnouncements
    def self.advanced_search(params = {})
      raise ArgumentError.new(":page and :per_page are required") unless params[:page].present? && params[:per_page].present?
      raise_unless_values_are_strings(params)

      scope = ::StatisticsAnnouncement.joins(:current_release_date).order("statistics_announcement_dates.release_date ASC")
      scope = scope.where("statistics_announcements.title LIKE('%#{params[:keywords]}%') or statistics_announcements.summary LIKE('%#{params[:keywords]}%')") if params[:keywords].present?
      if params[:organisations].present?
        organisation_ids = Organisation.find_all_by_slug(params[:organisations]).map &:id
        scope = scope.where(organisation_id: organisation_ids)
      end
      if params[:topics].present?
        topic_ids = Topic.find_all_by_slug(params[:topics]).map &:id
        scope = scope.where(topic_id: topic_ids)
      end
      if params[:release_timestamp].present?
        scope = scope.where("statistics_announcement_dates.release_date > ?", params[:release_timestamp][:from]) if params[:release_timestamp][:from].present?
        scope = scope.where("statistics_announcement_dates.release_date < ?", params[:release_timestamp][:to]) if params[:release_timestamp][:to].present?
      end

      scope = scope.group("statistics_announcements.id")
      count = scope.length
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
        "release_timestamp" => announcement.current_release_date.release_date.iso8601,
        "organisations" => Array(announcement.organisation.try :slug),
        "topics" => Array(announcement.topic.try :slug),
        "display_type" => announcement.publication_type.singular_name,
        "search_format_types" => ["statistics_announcement"],
        "format" => "statistics_announcement",
        "metadata" => {
          "confirmed" => announcement.current_release_date.confirmed,
          "display_date" => announcement.current_release_date.display_date,
          "change_note" => announcement.last_change_note,
          "previous_display_date" => announcement.previous_display_date
        }
      }
    end
  end
end
