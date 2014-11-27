module Whitehall
  # Whitehall-specific interface for accessing the Publishing API.
  #
  # This should in preference to accessing the API adapter or PublishingApiWorkers
  # directly when publishing or republishing models to the Publishing API.
  class PublishingApi
    def self.publish(model_instance)
      PublishingApiWorker.perform_async(model_instance.class.name, model_instance.id)
    end

    def self.republish(model_instance)
      PublishingApiWorker.perform_async(model_instance.class.name, model_instance.id, "republish")
    end
  end
end
