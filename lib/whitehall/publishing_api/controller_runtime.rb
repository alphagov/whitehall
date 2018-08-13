module Whitehall
  class PublishingApi
    module ControllerRuntime
      extend ActiveSupport::Concern

    protected

      def append_info_to_payload(payload)
        super
        payload[:publishing_api_runtime] =
          Whitehall::PublishingApi::LogSubscriber.reset_runtime
      end

      module ClassMethods
        def log_process_action(payload)
          messages = super
          publishing_api_runtime = payload[:publishing_api_runtime]
          if publishing_api_runtime
            messages.push("Publishing API: %.1fms" % publishing_api_runtime.to_f)
          end
          messages
        end
      end
    end
  end
end
