module PublishingApi
  class PublicationPresenter
    include UpdateTypeHelper

    attr_accessor :item, :update_type

    def initialize(item, update_type: nil)
      self.item = item
      self.update_type = update_type || default_update_type(item)
    end

    delegate :content_id, to: :item

    def content
      content = BaseItemPresenter.new(item, update_type: update_type).base_attributes
      content.merge!(
        description: item.summary,
        details: details,
        document_type: document_type,
        public_updated_at: item.public_timestamp || item.updated_at,
        rendering_app: item.rendering_app,
        schema_name: "publication",
        links: edition_links,
      )
      content.merge!(PayloadBuilder::PublicDocumentPath.for(item))
      content.merge!(PayloadBuilder::AccessLimitation.for(item))
      content.merge!(PayloadBuilder::FirstPublishedAt.for(item))
    end

    def links
      # TODO: Previously, this presenter was sending all links to the
      # Publishing API at both the document level, and edition
      # level. This is probably redundant, and hopefully can be
      # improved.
      edition_links
    end

    def edition_links
      LinksPresenter.new(item).extract(
        %i[
          topics
          parent
          organisations
          world_locations
          government
        ],
      ).merge(
        PayloadBuilder::TopicalEvents.for(item),
      ).merge(
        related_statistical_data_sets: related_statistical_data_sets,
      ).merge(
        PayloadBuilder::Roles.for(item),
      ).merge(
        PayloadBuilder::People.for(item),
      )
    end

    def document_type
      item.display_type_key
    end

  private

    def maybe_add_national_applicability(content)
      return content unless item.nation_inapplicabilities.any?

      content.merge(national_applicability: item.national_applicability)
    end

    def details
      details_hash = {
        body: body,
        change_history: item.change_history.as_json,
        documents: documents,
        featured_attachments: featured_attachments,
        emphasised_organisations: item.lead_organisations.map(&:content_id),
      }
      details_hash = maybe_add_national_applicability(details_hash)
      details_hash.merge!(PayloadBuilder::PoliticalDetails.for(item))
      details_hash.merge!(PayloadBuilder::TagDetails.for(item))
      details_hash.merge!(PayloadBuilder::FirstPublicAt.for(item))
      details_hash.merge!(PayloadBuilder::Attachments.for(item))
    end

    def body
      Whitehall::GovspeakRenderer.new.govspeak_edition_to_html(item)
    end

    def documents
      return [] unless item.attachments.any?

      Whitehall::GovspeakRenderer.new.block_attachments(
        attachments_for_current_locale,
        organisation_in_accessible_format_request?,
        alternative_format_email,
      )
    end

    def featured_attachments
      attachments_for_current_locale.map { |a| a.publishing_api_details[:id] }
    end

    def attachments_for_current_locale
      attachments = item.attachments
      # nil/"" locale should always be returned
      locales_that_match = [I18n.locale.to_s, ""]
      attachments.to_a.select do |attachment|
        locales_that_match.include?(attachment.locale.to_s)
      end
    end

    def related_statistical_data_sets
      item.statistical_data_sets.map(&:content_id)
    end

    def alternative_format_email
      item.alternative_format_provider.try(:alternative_format_contact_email)
    end

    def organisation_in_accessible_format_request?
      item.alternative_format_provider.try(:organisation_in_accessible_format_request_pilot)
    end
  end
end
