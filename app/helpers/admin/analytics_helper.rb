module Admin
  module AnalyticsHelper
    def track_analytics_data_on_load(title)
      {
        event_name: "page_view",
        page_view: {
          publishing_app: "Whitehall",
          user_created_at: current_user&.created_at&.to_date,
          user_organisation_name: current_user&.organisation_name,
          user_role: current_user&.role,
          document_type: title,
        },
      }.to_json
    end
  end
end
