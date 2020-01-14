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
      BaseItemPresenter
        .new(item, locale: locale, update_type: update_type)
        .base_attributes
        .merge(PayloadBuilder::Routes.for(base_path))
        .merge(
          base_path: base_path,
          description: nil,
          details: details,
          document_type: schema_name,
          public_updated_at: item.updated_at,
          rendering_app: item.rendering_app,
          schema_name: schema_name,
          links: edition_links,
      )
    end

    def links
      # TODO: Previously, this presenter was sending all links to the
      # Publishing API at both the document level, and edition
      # level. This is probably redundant, and hopefully can be
      # improved.
      edition_links
    end

    def edition_links
      {
        parent: parent_content_ids, # please use the breadcrumb component when migrating document_type to government-frontend
        organisations: parent.organisations.pluck(:content_id).uniq,
        primary_publishing_organisation: primary_publishing_organisation,
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
      details_hash = {
        body: body,
        public_timestamp: public_timestamp,
        first_published_version: first_published_version?,
      }
      details_hash.merge!(PayloadBuilder::BrexitNoDealContent.for(parent))
    end

    def body
      govspeak_content.try(:computed_body_html) || ""
    end

    def first_published_version?
      parent.first_published_version?
    end

    def public_timestamp
      parent.public_timestamp || parent.updated_at
    end

    def primary_publishing_organisation
      [lead_org_id || first_org_id].compact
    end

    def lead_org_id
      parent.try(:lead_organisations).try(:first).try(:content_id)
    end

    def first_org_id
      parent.try(:organisations).try(:first).try(:content_id)
    end

    def parent
      item.attachable
    end

    def parent_content_ids
      [parent.document.content_id]
    end

    def govspeak_content
      item.govspeak_content
    end

    def locale
      item.translated_locales.first
    end
  end
end
