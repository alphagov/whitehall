module SyncChecker
  class DetailedGuideCheck
    attr_reader :document, :results
    def initialize(detailed_guide_document)
      @document = detailed_guide_document
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
      path = "/guidance/#{document.slug}"
      path += ".#{locale}" unless locale.to_s == "en"
      path
    end

    def check_draft(response, locale)
      checks = [
        TopLevelCheck.new(
          top_level_fields_hash(edition_expected_in_draft.translation_for(locale))
        ),
        LinksCheck.new(
          "organisations",
          (edition_expected_in_draft.try(:organisations) || []).map(&:content_id)
        ),
        LinksCheck.new(
          "policy_areas",
          (edition_expected_in_draft.try(:topics) || []).map(&:content_id)
        ),
        DetailsCheck.new(
          I18n.with_locale(locale) do
            {
              body: Whitehall::GovspeakRenderer.new.govspeak_edition_to_html(edition_expected_in_live)
            }
          end
        )
      ]

      errors = checks.flat_map { |check| check.call(response) }

      return Failure.new(response.request.base_url, response.response_code, document.id, edition_expected_in_draft.id, locale, DRAFT_CONTENT_STORE, errors) if errors.any?
    end

    def check_live(response, locale)
      checks = [
        TopLevelCheck.new(
          top_level_fields_hash(edition_expected_in_live.translation_for(locale))
        ),
        LinksCheck.new(
          "organisations",
          (edition_expected_in_live.try(:organisations) || []).map(&:content_id)
        ),
        LinksCheck.new(
          "policy_areas",
          (edition_expected_in_live.try(:topics) || []).map(&:content_id)
        ),
        DetailsCheck.new(
          I18n.with_locale(locale) do
            {
              body: Whitehall::GovspeakRenderer.new.govspeak_edition_to_html(edition_expected_in_live)
            }
          end
        ),
        UnpublishedCheck.new(document)
      ]

      errors = checks.flat_map { |check| check.call(response) }

      return Failure.new(response.request.base_url, response.response_code, document.id, edition_expected_in_live.id, locale, LIVE_CONTENT_STORE, errors) if errors.any?
    end

  private

    def top_level_fields_hash(translation_for_locale)
      {
        analytics_identifier: nil,
        base_path: get_path(translation_for_locale.locale),
        content_id: document.content_id,
        document_type: "detailed_guidance",
        format: "detailed_guide",
        locale: translation_for_locale.locale.to_s,
        publishing_app: "whitehall",
        rendering_app: "whitehall-frontend",
        schema_name: "detailed_guide",
        title: translation_for_locale.title,
        description: translation_for_locale.summary
      }
    end
  end
end
