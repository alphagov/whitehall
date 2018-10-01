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
    def self.publish(model_instance, update_type_override = nil)
      assert_public_edition!(model_instance)

      # TODO: This should be unnecessary eventually, as the Publishing
      # API should be kept up to date. Once no content is rendered
      # through Whitehall Frontend, this can definately be removed, as
      # the previews will always be representative of what will be
      # published.
      save_draft(model_instance, update_type_override)

      presenter = PublishingApiPresenters.presenter_for(
        model_instance,
        update_type: update_type_override
      )

      locales_for(model_instance).each do |locale|
        I18n.with_locale(locale) do
          # TODO: This is probably redundant
          Services.publishing_api.patch_links(
            presenter.content_id,
            links: presenter.links
          )

          Services.publishing_api.publish(
            presenter.content_id,
            nil,
            locale: locale.to_s
          )
        end
      end
    end

    def self.save_draft(model_instance, update_type_override = nil)
      locales_for(model_instance).each do |locale|
        save_draft_translation(model_instance, locale, update_type_override)
      end
    end

    def self.save_draft_translation(
          model_instance,
          locale,
          update_type_override = nil
    )
      presenter = PublishingApiPresenters.presenter_for(
        model_instance,
        update_type: update_type_override
      )

      I18n.with_locale(locale) do
        Services.publishing_api.put_content(
          presenter.content_id,
          presenter.content
        )
      end
    end

    def self.republish_async(model_instance)
      if model_instance.class < Edition
        raise ArgumentError, "This method does not support Editions: call republish_document_async with the Document this Edition belongs to"
      end
      push_live(model_instance, 'republish')
    end

    def self.bulk_republish_async(model_instance)
      if model_instance.class < Edition
        raise ArgumentError, "This method does not support Editions"
      end
      push_live(model_instance, 'republish', 'bulk_republishing')
    end

    # Synchronise the published and/or draft documents in publishing-api with
    # the contents of Whitehall's database.
    def self.republish_document_async(document, bulk: false)
      queue = bulk ? 'bulk_republishing' : 'default'
      PublishingApiDocumentRepublishingWorker.perform_async_in_queue(
        queue,
        document.id
      )
    end

    def self.schedule_async(edition)
      publish_timestamp = edition.scheduled_publication.as_json
      locales_for(edition).each do |locale|
        base_path = Whitehall.url_maker.public_document_path(edition, locale: locale)
        PublishingApiScheduleWorker.perform_async(base_path, publish_timestamp)
        unless edition.document.published?
          PublishingApiComingSoonWorker.perform_async(edition.id, locale)
        end
      end
    end

    def self.unschedule_async(edition)
      locales_for(edition).each do |locale|
        base_path = Whitehall.url_maker.public_document_path(edition, locale: locale)
        PublishingApiUnscheduleWorker.perform_async(base_path)
        self.publish_vanish_async(edition.content_id, locale) unless edition.document.published?
      end
    end

    def self.publish_redirect_async(content_id, destination, locale = I18n.default_locale.to_s)
      PublishingApiRedirectWorker.perform_async(content_id, destination, locale)
    end

    def self.publish_gone_async(content_id, alternative_path, explanation, locale = I18n.default_locale.to_s)
      PublishingApiGoneWorker.perform_async(content_id, alternative_path, explanation, locale)
    end

    def self.publish_vanish_async(document_content_id, locale = I18n.default_locale.to_s)
      PublishingApiVanishWorker.perform_async(document_content_id, locale)
    end

    def self.publish_withdrawal_async(document_content_id, explanation, locale = I18n.default_locale.to_s)
      PublishingApiWithdrawalWorker.perform_async(document_content_id, explanation, locale)
    end

    def self.unpublish_async(unpublishing)
      PublishingApiUnpublishingWorker.perform_async(unpublishing.id)
    end

    def self.save_draft_redirect_async(base_path, redirects, locale = I18n.default_locale.to_s)
      PublishingApiRedirectWorker.perform_async(
        base_path,
        redirects,
        locale,
        draft: true
      )
    end

    def self.save_draft_gone_async(base_path)
      PublishingApiGoneWorker.perform_async(base_path, draft: true)
    end

    def self.discard_draft_async(edition)
      locales_for(edition).each do |locale|
        PublishingApiDiscardDraftWorker.perform_async(edition.content_id, locale)
      end
    end

    def self.discard_translation_async(edition, locale:)
      PublishingApiDiscardDraftWorker.perform_async(edition.content_id, locale)
    end

    def self.publish_services_and_information_async(organisation_id)
      PublishingApiServicesAndInformationWorker.perform_async(organisation_id)
    end

    def self.locales_for(model_instance)
      if model_instance.respond_to?(:translated_locales) && (locales = model_instance.translated_locales).any?
        locales
      else
        [:en]
      end
    end

    def self.push_live(model_instance, update_type_override = nil, queue_override = nil)
      self.assert_public_edition!(model_instance)
      locales_for(model_instance).each do |locale|
        PublishingApiWorker.perform_async_in_queue(queue_override, model_instance.class.name, model_instance.id, update_type_override, locale)
      end
    end

    def self.served_from_content_store?(edition)
      edition.rendering_app == Whitehall::RenderingApp::GOVERNMENT_FRONTEND
    end

    def self.assert_public_edition!(instance)
      if instance.is_a?(Edition) && !instance.publicly_visible?
        raise UnpublishableInstanceError, "#{instance.class} with ID #{instance.id} is not publishable"
      end
    end
  end
end
