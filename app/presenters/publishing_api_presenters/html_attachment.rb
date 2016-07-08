module PublishingApiPresenters
  class HtmlAttachment < Item
    def initialize(item, update_type: nil)
      super
      item.govspeak_content.try(:render_govspeak!)
    end

    def links
      {
        parent: parent_content_ids,
        organisations: parent.organisations.pluck(:content_id),
      }
    end

  private

    def schema_name
      "html_publication"
    end

    def details
      {
        body: body,
        headings: headings,
        public_timestamp: public_timestamp,
        first_published_version: first_published_version?
      }
    end

    def base_path
      item.url
    end

    def description
      #not used in this format
    end

    def public_updated_at
      item.updated_at
    end

    def body
      govspeak_content.try(:computed_body_html)
    end

    def headings
      govspeak_content.try(:computed_headers_html)
    end

    def first_published_version?
      parent.first_published_version?
    end

    def public_timestamp
      parent.public_timestamp
    end

    def parent
      item.attachable
    end

    def parent_content_ids
      ::Edition.joins(:document).where(editions: {id: item.attachable_id}).pluck(:content_id)
    end

    def govspeak_content
      item.govspeak_content
    end

    def locale
      item.translated_locales.first
    end
  end
end
