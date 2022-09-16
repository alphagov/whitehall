module PublishingApi
  class HtmlAttachmentPresenter
    attr_accessor :item, :update_type

    def initialize(item, update_type: nil)
      self.item = item
      self.update_type = update_type || "major"
      item.govspeak_content.try(:render_govspeak!)
    end

    delegate :content_id, to: :item

    def content
      BaseItemPresenter
        .new(item, locale:, update_type:)
        .base_attributes
        .merge(PayloadBuilder::Routes.for(base_path))
        .merge(
          base_path:,
          description: nil,
          details:,
          document_type: schema_name,
          public_updated_at: item.updated_at,
          rendering_app: item.rendering_app,
          schema_name:,
          links: edition_links,
          auth_bypass_ids: [parent.auth_bypass_id],
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
        primary_publishing_organisation:,
        government: government_id,
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
        body:,
        public_timestamp:,
        first_published_version: first_published_version?,
        political: political?,
      }

      maybe_add_national_applicability(details_hash)
    end

    def maybe_add_national_applicability(details_hash)
      return details_hash unless item.attachable.try(:nation_inapplicabilities)&.any?

      details_hash.merge(national_applicability: item.attachable.national_applicability)
    end

    def body
      govspeak_content.try(:computed_body_html) || ""
    end

    def first_published_version?
      parent.first_published_version?
    end

    def political?
      item&.attachable.is_a?(Edition) ? item&.attachable&.political : false
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

    def government_id
      [parent.try(:government).try(:content_id)].compact
    end
  end
end
