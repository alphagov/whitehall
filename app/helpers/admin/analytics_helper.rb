module Admin
  module AnalyticsHelper
    def track_analytics_data(type, message)
      {
        'module' => 'auto-track-event',
        'track-action' => "alert-#{type}",
        'track-label' => strip_tags(message),
      }
    end
  end
end
