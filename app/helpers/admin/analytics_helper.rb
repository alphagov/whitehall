module Admin
  module AnalyticsHelper
    def track_analytics_data(category, action, label)
      {
        'module' => 'auto-track-event',
        'track-category' => category,
        'track-action' => action,
        'track-label' => ActionController::Base.helpers.strip_tags(label),
      }
    end
  end
end
