module Whitehall
  class PublishingApi
    class LogSubscriber < ActiveSupport::LogSubscriber
      def self.runtime=(value)
        Thread.current["publishing_api_runtime"] = value
      end

      def self.runtime
        Thread.current["publishing_api_runtime"] ||= 0
      end

      def self.reset_runtime
        runtime_before_reset = self.runtime
        self.runtime = 0
        runtime_before_reset
      end

      def process_event(event)
        self.class.runtime += event.duration

        return unless logger.debug?

        name = 'Publishing API (%.1fms)' % event.duration

        debug "  #{color(name, YELLOW, true)} [ #{event.payload[:event]}, options: #{event.payload[:options]} ]"
      end
    end
  end
end
