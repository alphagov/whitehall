module Whitehall
  # Whitehall-specific interface for accessing the Publishing API.
  #
  # This should be used in preference to accessing the API adapter or
  # PublishingApiWorkers directly when publishing or republishing models to the
  # Publishing API.
  class PublishingApi
    def self.publish(model_instance)
      locales_for(model_instance).each do |locale|
        PublishingApiWorker.perform_async(model_instance.class.name, model_instance.id, nil, locale)
      end
    end

    def self.republish(model_instance)
      locales_for(model_instance).each do |locale|
        PublishingApiWorker.perform_async(model_instance.class.name, model_instance.id, "republish", locale)
      end
    end

  private

    # Note: this method does not account for non-translatable models, e.g.
    # PolicyGroup. Once we are pushing those to the Publishing API, this method
    # will need updating to return just the English locale for those models.
    def self.locales_for(model_instance)
      model_instance.translated_locales
    end
  end
end
