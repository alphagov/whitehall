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
              expected_details_hash(edition_expected_in_draft)
            end
          ),
          Checks::TranslationsCheck.new(edition_expected_in_draft.available_locales)
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
          Checks::LinksCheck.new(
            "related_policies",
            (edition_expected_in_live.try(:policy_content_ids) || [])
          ),
          Checks::DetailsCheck.new(
            I18n.with_locale(locale) do
              expected_details_hash(edition_expected_in_live)
            end
          ),
          Checks::UnpublishedCheck.new(document),
          Checks::TranslationsCheck.new(edition_expected_in_live.available_locales),
          Checks::TopicsCheck.new(edition_expected_in_live)
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

      def expected_details_hash(edition)
        {
          body: Whitehall::GovspeakRenderer.new.govspeak_edition_to_html(edition),
          change_history: edition.change_history.as_json,
          emphasised_organisations: edition.lead_organisations.map(&:content_id),
          first_public_at: first_public_at(edition),
          political: edition.political?,
          government: expected_government_value(edition)
        }
      end

    private

      def top_level_fields_hash(translation_for_locale)
        {
          base_path: get_path(translation_for_locale.locale),
          content_id: document.content_id,
          document_type: document_type,
          locale: translation_for_locale.locale.to_s,
          publishing_app: "whitehall",
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

      def first_public_at(edition)
        (document.published? ? edition.first_public_at : document.created_at).try(:iso8601)
      end

      def expected_government_value(edition)
        government = edition.government
        return unless government
        {
          title: government.name,
          slug: government.slug,
          current: government.current?
        }.stringify_keys
      end
    end
  end
end
