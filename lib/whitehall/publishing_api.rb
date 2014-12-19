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

    def self.schedule(model_instance)
      locales_for(model_instance).each do |locale|
        PublishingApiScheduleWorker.perform_async(model_instance.class.name, model_instance.id, locale)
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
      return unless should_publish?(model_instance)
      self.assert_public_edition!(model_instance)
      locales_for(model_instance).each do |locale|
        PublishingApiWorker.perform_async(model_instance.class.name, model_instance.id, update_type_override, locale)
      end
    end

    def self.should_publish?(instance)
      if instance.kind_of?(Unpublishing)
        instance.edition.kind_of?(CaseStudy)
      else
        true
      end
    end

    def self.assert_public_edition!(instance)
      if instance.kind_of?(Edition) && !instance.publicly_visible?
        raise UnpublishableInstanceError, "#{instance.class} with ID #{instance.id} is not publishable"
      end
    end
  end
end
