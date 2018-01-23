module Admin
  module AnalyticsHelper
    def track_analytics_data(category, type, message)
      {
        'module' => 'auto-track-event',
        'track-category' => category,
        'track-action' => "alert-#{type}",
        'track-label' => strip_tags(message),
      }
    end
  end
end
