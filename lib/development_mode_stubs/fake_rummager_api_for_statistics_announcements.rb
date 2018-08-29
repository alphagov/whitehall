module DevelopmentModeStubs
  class FakeRummagerApiForStatisticsAnnouncements
    class << self
      def advanced_search(params = {})
        raise ArgumentError.new(":page and :per_page are required") unless params[:page].present? && params[:per_page].present?
        raise_unless_values_are_strings(params)

        scope = ::StatisticsAnnouncement.joins(:current_release_date).order("statistics_announcement_dates.release_date ASC")

        if params[:keywords].present?
          scope = scope.where(
            "statistics_announcements.title LIKE ? OR statistics_announcements.summary LIKE ?",
            "%#{params[:keywords]}%",
            "%#{params[:keywords]}%"
          )
        end

        if params[:organisations].present?
          organisation_ids = Organisation.where(slug: params[:organisations]).pluck(:id)
          scope = scope.in_organisations(organisation_ids)
        end
        if params[:policy_areas].present?
          topic_ids = Topic.where(slug: params[:policy_areas]).pluck(:id)
          scope = scope.with_topics(topic_ids)
        end
        if params[:release_timestamp].present?
          scope = scope.where("statistics_announcement_dates.release_date > ?", params[:release_timestamp][:from]) if params[:release_timestamp][:from].present?
          scope = scope.where("statistics_announcement_dates.release_date < ?", params[:release_timestamp][:to]) if params[:release_timestamp][:to].present?
        end
        if params[:statistics_announcement_state] == 'cancelled'
          scope = scope.where("cancelled_at IS NOT NULL")
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

      def raise_unless_values_are_strings(param_hash)
        param_hash.each do |key, value|
          if value.is_a? Hash
            raise_unless_values_are_strings(value)
          elsif !(value.is_a?(String) || value.is_a?(Array))
            raise ArgumentError.new("Search paramaters must be provided as strings, :#{key} was a #{value.class.name}")
          end
        end
      end

      def announcement_to_rummager_hash(announcement)
        {
          "title" => announcement.title,
          "description" => announcement.summary,
          "slug" => announcement.slug,
          "release_timestamp" => announcement.current_release_date.release_date.iso8601,
          "organisations" => announcement.organisations_slugs,
          "policy_areas" => announcement.topic_slugs,
          "display_type" => announcement.publication_type.singular_name,
          "search_format_types" => %w[statistics_announcement],
          "format" => "statistics_announcement",
          "statistics_announcement_state" => announcement.state,
          "metadata" => {
            "confirmed" => announcement.current_release_date.confirmed,
            "display_date" => announcement.current_release_date.display_date,
            "change_note" => announcement.last_change_note,
            "previous_display_date" => announcement.previous_display_date,
            "cancellation_reason" => announcement.cancellation_reason,
            "cancellation_date" => announcement.cancelled_at,
          }
        }
      end
    end
  end
end
