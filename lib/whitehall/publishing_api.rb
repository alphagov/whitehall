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
    def self.publish_async(model_instance, update_type_override=nil, queue_override=nil)
      push_live(model_instance, update_type_override, queue_override)
    end

    def self.save_draft_async(model_instance, update_type_override = nil, queue_override = nil)
      return if skip_sending_to_content_store?(model_instance)
      locales_for(model_instance).each do |locale|
        PublishingApiDraftWorker.perform_async_in_queue(queue_override, model_instance.class.name, model_instance.id, update_type_override, locale)
      end
    end

    def self.republish_async(model_instance)
      push_live(model_instance, 'republish')
    end

    def self.schedule_async(edition)
      return unless served_from_content_store?(edition)
      publish_timestamp = edition.scheduled_publication.as_json
      locales_for(edition).each do |locale|
        base_path = Whitehall.url_maker.public_document_path(edition, locale: locale)
        PublishingApiScheduleWorker.perform_async(base_path, publish_timestamp)
        unless edition.document.published?
          PublishingApiComingSoonWorker.perform_async(edition.id, locale)
                                      # perform_async(base_path, publish_timestamp, locale)
        end
      end
    end

    def self.unschedule_async(edition)
      return unless served_from_content_store?(edition)
      locales_for(edition).each do |locale|
        base_path = Whitehall.url_maker.public_document_path(edition, locale: locale)
        PublishingApiUnscheduleWorker.perform_async(base_path)
        self.publish_gone(base_path) unless edition.document.published?
      end
    end

    def self.publish_redirect_async(base_path, redirects, locale = I18n.default_locale.to_s)
      PublishingApiRedirectWorker.perform_async(base_path, redirects, locale)
    end

    def self.publish_gone(base_path)
      PublishingApiGoneWorker.perform_async(base_path)
    end

    def self.discard_draft_async(edition)
      PublishingApiDiscardDraftWorker.perform_async(edition.content_id, edition.translations.map(&:locale))
    end

  private

    def self.locales_for(model_instance)
      if model_instance.respond_to?(:translated_locales) && (locales = model_instance.translated_locales).any?
        locales
      else
        [:en]
      end
    end

    def self.push_live(model_instance, update_type_override=nil, queue_override=nil)
      return if skip_sending_to_content_store?(model_instance)
      self.assert_public_edition!(model_instance)
      locales_for(model_instance).each do |locale|
        PublishingApiWorker.perform_async_in_queue(queue_override, model_instance.class.name, model_instance.id, update_type_override, locale)
      end
    end

    def self.served_from_content_store?(edition)
      edition.kind_of?(CaseStudy)
    end

    # We want to avoid sending unpublishings for content types which are not
    # managed by the content store at present. Background is here:
    # http://github.com/alphagov/whitehall/commit/6affc9da0d8ca93
    def self.skip_sending_to_content_store?(instance)
      unpublishing_not_served_from_content_store?(instance)
    end

    def self.unpublishing_not_served_from_content_store?(instance)
      instance.kind_of?(Unpublishing) && !served_from_content_store?(instance.edition)
    end

    def self.assert_public_edition!(instance)
      if instance.kind_of?(Edition) && !instance.publicly_visible?
        raise UnpublishableInstanceError, "#{instance.class} with ID #{instance.id} is not publishable"
      end
    end
  end
end
