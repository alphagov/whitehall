module SyncChecker
  module Formats
    class EditionBase
      def self.scope
        klass = self.name.demodulize.sub(/Check$/, '')
        Document.where(id: klass.constantize.all.pluck(:document_id).uniq)
      end

      def self.scope_with_ids(ids)
        Document.where(id: ids)
      end

      def self.republish(id)
        PublishingApiDocumentRepublishingWorker.new.perform(id)
      end

      attr_reader :document, :results
      def initialize(document)
        @document = document
        @results = []
      end

      def edition_expected_in_draft
        document.pre_publication_edition || document.published_edition
      end

      def edition_expected_in_live
        case
        when document.published_edition
          document.published_edition
        when document.pre_publication_edition && document.pre_publication_edition.unpublishing
          document.pre_publication_edition
        end
      end

      def base_paths
        @base_paths ||= {draft: {}, live: {}}.tap do |paths|
          if edition_expected_in_draft
            edition_expected_in_draft.translated_locales.each do |locale|
              paths[:draft][locale] = get_path(locale)
            end
          end

          if edition_expected_in_live
            edition_expected_in_live.translated_locales.each do |locale|
              paths[:live][locale] = get_path(locale)
            end
          end
        end
      end

      def get_path(locale)
        path = "#{root_path}#{document.slug}"
        path += ".#{locale}" unless locale.to_s == "en"
        path
      end

      def checks_for_draft(locale)
        [
          Checks::TopLevelCheck.new(
            top_level_fields_hash(edition_expected_in_draft.translation_for(locale))
          ),
          Checks::DetailsCheck.new(
            I18n.with_locale(locale) do
              {
                body: Whitehall::GovspeakRenderer.new.govspeak_edition_to_html(edition_expected_in_draft)
              }
            end
          )
        ]
      end

      def check_draft(response, locale)
        errors = checks_for_draft(locale).flat_map { |check| check.call(response) }

        if errors.any?
          return Failure.new(
            response.request.base_url,
            response.response_code,
            document.id,
            edition_expected_in_draft.id,
            locale,
            DRAFT_CONTENT_STORE,
            errors
          )
        end
      end

      def checks_for_live(locale)
        [
          Checks::TopLevelCheck.new(
            top_level_fields_hash(edition_expected_in_live.translation_for(locale))
          ),
          Checks::LinksCheck.new(
            "organisations",
            (edition_expected_in_live.try(:organisations) || []).map(&:content_id)
          ),
          Checks::LinksCheck.new(
            "policy_areas",
            (edition_expected_in_live.try(:topics) || []).map(&:content_id)
          ),
          Checks::DetailsCheck.new(
            I18n.with_locale(locale) do
              {
                body: Whitehall::GovspeakRenderer.new.govspeak_edition_to_html(edition_expected_in_live)
              }
            end
          ),
          Checks::UnpublishedCheck.new(document)
        ]
      end

      def check_live(response, locale)
        errors = checks_for_live(locale).flat_map { |check| check.call(response) }

        if errors.any?
          return Failure.new(
            response.request.base_url,
            response.response_code,
            document.id,
            edition_expected_in_live.id,
            locale,
            LIVE_CONTENT_STORE,
            errors
          )
        end
      end

    private

      def top_level_fields_hash(translation_for_locale)
        {
          analytics_identifier: nil,
          base_path: get_path(translation_for_locale.locale),
          content_id: document.content_id,
          document_type: document_type,
          locale: translation_for_locale.locale.to_s,
          publishing_app: "whitehall",
          rendering_app: rendering_app,
          schema_name: document.document_type.underscore,
          title: translation_for_locale.title,
          description: translation_for_locale.summary,
          rendering_app: rendering_app
        }
      end

      def rendering_app
        Whitehall::RenderingApp::WHITEHALL_FRONTEND
      end

      def document_type
        document.document_type.underscore
      end
    end
  end
end
