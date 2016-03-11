module Admin
  module AnalyticsHelper
    def track_analytics_data(type, message)
      {
        'module' => 'auto-track-event',
        'track-action' => "alert-#{type}",
        'track-label' => message,
      }
    end
  end
end
