module PublishingApi
  class StatisticsAnnouncementPresenter
    attr_accessor :item
    attr_accessor :update_type

    def initialize(item, update_type: nil) # rubocop:disable Lint/UnusedMethodArgument
      self.item = item
      self.update_type = "minor"
    end

    def content_id
      item.content_id
    end

    def content
      content = BaseItemPresenter.new(
        item,
        update_type: update_type,
      ).base_attributes

      content.merge!(
        description: item.summary,
        details: details,
        document_type: document_type,
        public_updated_at: item.updated_at,
        rendering_app: Whitehall::RenderingApp::GOVERNMENT_FRONTEND,
        schema_name: "statistics_announcement",
      )
      content.merge!(PayloadBuilder::PolymorphicPath.for(item))
    end

    def links
      LinksPresenter.new(item).extract([
        :organisations,
        :policy_areas,
      ])
    end

  private

    def document_type
      item.national_statistic? ? "national_statistics_announcement" : "official_statistics_announcement"
    end

    def details
      {
        display_date: item.current_release_date.display_date,
        state: item.state,
        format_sub_type: format_sub_type
      }.tap do |d|
        if item.cancelled?
          d[:cancellation_reason] = item.cancellation_reason
          d[:cancelled_at] = cancelled_at
        end
        if item.previous_display_date
          d.merge!(
            previous_display_date: item.previous_display_date,
            latest_change_note: item.last_change_note
          )
        end
      end
    end

    def format_sub_type
      item.national_statistic? ? "national" : "official"
    end

    def cancelled_at
      return nil unless item.cancelled_at
      item.cancelled_at.to_datetime
    end
  end
end
