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
    def self.publish(model_instance, update_type_override = nil, bulk_publishing: false)
      assert_public_edition!(model_instance)

      # Ideally this wouldn't happen, but aspects of Whitehall still
      # depend on this behaviour, as the drafts sent to the Publishing
      # API are not suitable for publishing.
      #
      # For example, the change notes only include changes from
      # published editions in Whitehall, so the edition in Whitehall
      # needs to be published, then the draft updated in the
      # Publishing API updated to update the change notes (and
      # possibly other things), and only then can it be published.
      save_draft(
        model_instance,
        update_type_override,
        bulk_publishing:,
      )

      presenter = PublishingApiPresenters.presenter_for(model_instance)

      locales_for(model_instance).each do |locale|
        I18n.with_locale(locale) do
          Services.publishing_api.publish(
            presenter.content_id,
            nil,
            locale: locale.to_s,
          )
        end
      end
    rescue GdsApi::HTTPUnprocessableEntity => e
      if model_instance.instance_of?(WorldwideOrganisation) && e.message =~ /conflicts with content_id/
        nil
      elsif e.message =~ /conflicts with content_id/
        raise UnpublishableInstanceError, e.message
      else
        raise
      end
    end

    def self.save_draft(model_instance, update_type_override = nil, bulk_publishing: false)
      locales_for(model_instance).each do |locale|
        save_draft_translation(model_instance, locale, update_type_override, bulk_publishing:)
      end
    end

    def self.save_draft_translation(
      model_instance,
      locale,
      update_type_override = nil,
      bulk_publishing: false
    )
      presenter = PublishingApiPresenters.presenter_for(
        model_instance,
        update_type: update_type_override,
      )

      I18n.with_locale(locale) do
        content = presenter.content

        content.merge!(bulk_publishing: true) if bulk_publishing

        Services.publishing_api.put_content(presenter.content_id, content)
      end
    rescue GdsApi::HTTPUnprocessableEntity => e
      if e.message =~ /already reserved/
        raise UnpublishableInstanceError, e.message
      else
        raise
      end
    end

    def self.patch_links(model_instance, bulk_publishing: false)
      presenter = PublishingApiPresenters.presenter_for(model_instance)

      links = presenter.links
      return if links.empty?

      Services.publishing_api.patch_links(
        presenter.content_id,
        links:,
        bulk_publishing:,
      )
    end

    def self.republish_async(model_instance)
      if model_instance.class < Edition
        raise ArgumentError, "This method does not support Editions: call republish_document_async with the Document this Edition belongs to"
      end

      push_live(model_instance, "republish")
    end

    def self.bulk_republish_async(model_instance)
      if model_instance.class < Edition
        raise ArgumentError, "This method does not support Editions"
      end

      push_live(model_instance, "republish", "bulk_republishing")
    end

    # Synchronise the published and/or draft documents in publishing-api with
    # the contents of Whitehall's database.
    def self.republish_document_async(document, bulk: false)
      queue = bulk ? "bulk_republishing" : "default"
      PublishingApiDocumentRepublishingWorker.perform_async_in_queue(
        queue,
        document.id,
        bulk,
      )
    end

    def self.schedule_async(edition)
      publish_timestamp = edition.scheduled_publication.as_json
      locales_for(edition).each do |locale|
        base_path = edition.public_path(locale:)
        PublishingApiScheduleWorker.perform_async(base_path, publish_timestamp)
      end
    end

    def self.unschedule_async(edition)
      locales_for(edition).each do |locale|
        base_path = edition.public_path(locale:)
        PublishingApiUnscheduleWorker.perform_async(base_path)
      end
    end

    def self.publish_redirect_async(content_id, destination, locale = I18n.default_locale.to_s)
      PublishingApiRedirectWorker.perform_async(content_id, destination, locale.to_s)
    end

    def self.publish_gone_async(content_id, alternative_path, explanation, locale = I18n.default_locale.to_s)
      PublishingApiGoneWorker.perform_async(content_id, alternative_path, explanation, locale.to_s)
    end

    def self.publish_vanish_async(document_content_id, locale = I18n.default_locale.to_s)
      PublishingApiVanishWorker.perform_async(document_content_id, locale.to_s)
    end

    def self.publish_withdrawal_async(document_content_id, explanation, unpublished_at, locale = I18n.default_locale.to_s)
      PublishingApiWithdrawalWorker.perform_async(document_content_id, explanation, locale.to_s, false, unpublished_at.to_s)
    end

    def self.unpublish_async(unpublishing)
      PublishingApiUnpublishingWorker.perform_async(unpublishing.id)
    end

    def self.save_draft_redirect_async(base_path, redirects, locale = I18n.default_locale.to_s)
      PublishingApiRedirectWorker.perform_async(
        base_path,
        redirects,
        locale.to_s,
        draft: true,
      )
    end

    def self.save_draft_gone_async(base_path)
      PublishingApiGoneWorker.perform_async(base_path, draft: true)
    end

    def self.discard_draft_async(edition)
      locales_for(edition).each do |locale|
        PublishingApiDiscardDraftWorker.perform_async(edition.content_id, locale.to_s)
      end
    end

    def self.discard_translation_async(edition, locale:)
      PublishingApiDiscardDraftWorker.perform_async(edition.content_id, locale.to_s)
    end

    def self.locales_for(model_instance)
      if model_instance.respond_to?(:translated_locales) && (locales = model_instance.translated_locales).any?
        locales
      else
        [:en]
      end
    end

    def self.push_live(model_instance, update_type_override = nil, queue_override = nil)
      assert_public_edition!(model_instance)
      locales_for(model_instance).each do |locale|
        PublishingApiWorker.perform_async_in_queue(queue_override, model_instance.class.name, model_instance.id, update_type_override, locale.to_s)
      end
    end

    def self.assert_public_edition!(instance)
      if instance.is_a?(Edition) && !instance.publicly_visible?
        raise UnpublishableInstanceError, "#{instance.class} with ID #{instance.id} is not publishable"
      end
    end
  end
end
