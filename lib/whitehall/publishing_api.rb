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
    def self.publish_async(model_instance, update_type_override=nil)
      do_action(model_instance, update_type_override)
    end

    def self.publish_draft_async(model_instance, update_type_override=nil, queue_override=nil)
      return unless should_publish?(model_instance)
      locales_for(model_instance).each do |locale|
        PublishingApiDraftWorker.perform_async_in_queue(queue_override, model_instance.class.name, model_instance.id, update_type_override, locale)
      end
    end

    def self.republish_async(model_instance)
      do_action(model_instance, 'republish')
    end

    def self.schedule_async(edition)
      return unless served_from_content_store?(edition)
      publish_timestamp = edition.scheduled_publication.as_json
      locales_for(edition).each do |locale|
        base_path = Whitehall.url_maker.public_document_path(edition, locale: locale)
        PublishingApiScheduleWorker.perform_async(base_path, publish_timestamp)
        unless edition.document.published?
          PublishingApiComingSoonWorker.perform_async(base_path, publish_timestamp, locale)
        end
      end
    end

    def self.unschedule_async(edition)
      return unless served_from_content_store?(edition)
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
      return unless should_publish?(model_instance)
      self.assert_public_edition!(model_instance)
      locales_for(model_instance).each do |locale|
        PublishingApiWorker.perform_async(model_instance.class.name, model_instance.id, update_type_override, locale)
      end
    end

    def self.served_from_content_store?(edition)
      edition.kind_of?(CaseStudy)
    end

    def self.should_publish?(instance)
      if instance.kind_of?(Unpublishing)
        served_from_content_store?(instance.edition)
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
