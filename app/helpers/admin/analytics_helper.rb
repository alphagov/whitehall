module Admin
  module AnalyticsHelper
    def track_analytics_data(type, message)
      {
        'module' => 'auto-track-event',
        'track-action' => "alert-#{type}",
        'track-label' => flash_text_without_email_addresses(message),
      }
    end

    def flash_text_without_email_addresses(message)
      text_message = strip_tags(message)

      # redact email addresses so they aren't passed to GA
      text_message.gsub(/\S+@\S+/, '[email]')
    end
  end
end
