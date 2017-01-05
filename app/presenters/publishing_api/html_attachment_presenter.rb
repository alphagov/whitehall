module PublishingApi
  class HtmlAttachmentPresenter
    attr_accessor :item
    attr_accessor :update_type

    def initialize(item, update_type: nil)
      self.item = item
      self.update_type = update_type || "major"
      item.govspeak_content.try(:render_govspeak!)
    end

    def content_id
      item.content_id
    end

    def content
      content = BaseItemPresenter.new(
        item,
        need_ids: [],
        locale: locale,
      ).base_attributes

      content.merge!(
        base_path: base_path,
        description: nil,
        details: details,
        document_type: schema_name,
        public_updated_at: item.updated_at,
        rendering_app: item.rendering_app,
        schema_name: schema_name,
      )
      content.merge!(PayloadBuilder::Routes.for(base_path))
    end

    def links
      {
        parent: parent_content_ids, # please use the breadcrumb component when migrating document_type to government-frontend
        organisations: parent.organisations.pluck(:content_id),
      }
    end

  private

    def schema_name
      "html_publication"
    end

    def base_path
      item.url
    end

    def details
      {
        body: body,
        headings: headings,
        public_timestamp: public_timestamp,
        first_published_version: first_published_version?
      }
    end

    def body
      govspeak_content.try(:computed_body_html) || ""
    end

    def headings
      govspeak_content.try(:computed_headers_html) || ""
    end

    def first_published_version?
      parent.first_published_version?
    end

    def public_timestamp
      parent.public_timestamp || parent.updated_at
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
