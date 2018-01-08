module PublishingApi
  class StatisticsAnnouncementPresenter
    attr_accessor :item
    attr_accessor :update_type

    def initialize(item, update_type: nil)
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
        d.merge!(
          cancellation_reason: item.cancellation_reason,
          cancelled_at: cancelled_at
        ) if item.cancelled?
        d.merge!(
          previous_display_date: item.previous_display_date,
          latest_change_note: item.last_change_note
        ) if item.previous_display_date
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
