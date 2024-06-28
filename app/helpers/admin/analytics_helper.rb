module Admin
  module AnalyticsHelper
    def track_analytics_data(category, action, label)
      {
        "module" => "auto-track-event",
        "track-category" => category,
        "track-action" => action,
        "track-label" => ActionController::Base.helpers.strip_tags(label),
      }
    end

    def track_analytics_data_on_load(title)
      {
        event_name: "page_view",
        page_view: {
          government_department_name: "Government Digital Service",
          access_level: current_user&.permissions,
          publishing_app: "Whitehall",
          user_created_at: current_user&.created_at&.to_date,
          document_type: title,
        },
      }.to_json
    end
  end
end
