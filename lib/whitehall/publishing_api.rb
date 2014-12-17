module Whitehall
  # Whitehall-specific interface for accessing the Publishing API.
  #
  # This should be used in preference to accessing the API adapter or
  # PublishingApiWorkers directly when publishing or republishing models to the
  # Publishing API.
  #
  # publish and republish raise UnpublishableInstanceError if the model instance
  # is not suitable for publishing to the API.
  class UnpublishableInstanceError < StandardError; end

  class PublishingApi
    def self.publish(model_instance)
      do_action(model_instance)
    end

    def self.republish(model_instance)
      do_action(model_instance, 'republish')
    end

    def self.schedule(edition)
      locales_for(edition).each do |locale|
        PublishingApiScheduleWorker.perform_async(edition.id, locale)
      end
    end

    def self.unschedule(edition)
      locales_for(edition).each do |locale|
        base_path = Whitehall.url_maker.public_document_path(edition, locale: locale)
        PublishingApiUnscheduleWorker.perform_async(base_path)
        PublishingApiGoneWorker.perform_async(base_path) unless edition.document.published?
      end
    end

  private

    # Note: this method does not account for non-translatable models, e.g.
    # PolicyGroup. Once we are pushing those to the Publishing API, this method
    # will need updating to return just the English locale for those models.
    def self.locales_for(model_instance)
      model_instance.translated_locales
    end

    def self.do_action(model_instance, update_type_override=nil)
      unless publishable?(model_instance)
        raise UnpublishableInstanceError, "#{model_instance.class} with ID #{model_instance.id} is not publishable"
      end
      locales_for(model_instance).each do |locale|
        PublishingApiWorker.perform_async(model_instance.class.name, model_instance.id, update_type_override, locale)
      end
    end

    def self.publishable?(instance)
      !instance.kind_of?(Edition) || instance.publicly_visible?
    end
  end
end
