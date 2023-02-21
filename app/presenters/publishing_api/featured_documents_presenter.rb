module PublishingApi
  module FeaturedDocumentsPresenter
    def featured_documents(featurable_item, document_limit)
      featurable_item.feature_list_for_locale(I18n.locale).current.limit(document_limit).map do |feature|
        if feature.document
          featured_documents_editioned(feature)
        elsif feature.topical_event
          featured_documents_topical_event(feature)
        elsif feature.offsite_link
          featured_documents_offsite_link(feature)
        end
      end
    end

  private

    def featured_documents_editioned(feature)
      # Editioned formats (like news) that have been featured
      edition = feature.document.live_edition
      {
        title: edition.title,
        href: edition.public_path(locale: feature.feature_list.locale),
        image: {
          url: feature.image.url,
          alt_text: feature.alt_text,
        },
        summary: Whitehall::GovspeakRenderer.new.govspeak_to_html(edition.summary),
        public_updated_at: edition.public_timestamp,
        document_type: edition.display_type,
      }
    end

    def featured_documents_topical_event(feature)
      # Topical events that have been featured
      topical_event = feature.topical_event
      {
        title: topical_event.name,
        href: topical_event.public_path(locale: feature.feature_list.locale),
        image: {
          url: feature.image.url,
          alt_text: feature.alt_text,
        },
        summary: Whitehall::GovspeakRenderer.new.govspeak_to_html(topical_event.summary),
        public_updated_at: topical_event.start_date,
        document_type: nil, # We don't want a type for topical events
      }
    end

    def featured_documents_offsite_link(feature)
      # Offsite links that have been featured
      offsite_link = feature.offsite_link
      {
        title: offsite_link.title,
        href: offsite_link.url,
        image: {
          url: feature.image.url,
          alt_text: feature.alt_text,
        },
        summary: Whitehall::GovspeakRenderer.new.govspeak_to_html(offsite_link.summary),
        public_updated_at: offsite_link.date,
        document_type: offsite_link.display_type,
      }
    end
  end
end
