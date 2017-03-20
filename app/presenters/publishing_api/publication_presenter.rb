module PublishingApi
  class PublicationPresenter
    include UpdateTypeHelper

    attr_accessor :item
    attr_accessor :update_type

    def initialize(item, update_type: nil)
      self.item = item
      self.update_type = update_type || default_update_type(item)
    end

    def content_id
      item.content_id
    end

    def content
      content = BaseItemPresenter.new(item).base_attributes
      content.merge!(
        description: item.summary,
        details: details,
        document_type: item.display_type_key,
        public_updated_at: item.public_timestamp || item.updated_at,
        #TODO: rendering app is hard coded until
        #item.rendering_app is switched when preview is ready
        rendering_app: Whitehall::RenderingApp::GOVERNMENT_FRONTEND,
        schema_name: "publication",
      )
      content.merge!(PayloadBuilder::PublicDocumentPath.for(item))
      content.merge!(PayloadBuilder::AccessLimitation.for(item))
      content.merge!(PayloadBuilder::FirstPublishedAt.for(item))
    end

    def links
      LinksPresenter.new(item).extract(
        [
          :topics,
          :parent,
          :organisations,
          :world_locations,
          :policy_areas,
          :related_policies,
        ]
      ).merge(
        PayloadBuilder::TopicalEvents.for(item)
      ).merge(
        ministers: ministers,
        related_statistical_data_sets: related_statistical_data_sets,
      ).merge(
        PayloadBuilder::Roles.for(item)
      ).merge(
        PayloadBuilder::People.for(item, :people)
      )
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
        emphasised_organisations: item.lead_organisations.map(&:content_id),
      }
      details_hash = maybe_add_national_applicability(details_hash)
      details_hash.merge!(PayloadBuilder::PoliticalDetails.for(item))
      details_hash.merge!(PayloadBuilder::TagDetails.for(item))
      details_hash.merge!(PayloadBuilder::FirstPublicAt.for(item))
    end

    def body
      Whitehall::GovspeakRenderer.new.govspeak_edition_to_html(item)
    end

    def documents
      return [] unless item.attachments.any?
      Whitehall::GovspeakRenderer.new.block_attachments(
        attachments_for_current_locale,
        alternative_format_email
      )
    end

    def attachments_for_current_locale
      attachments = item.attachments
      #nil/"" locale should always be returned
      locales_that_match = [I18n.locale.to_s, ""]
      attachments.to_a.select do |attachment|
        locales_that_match.include?(attachment.locale.to_s)
      end
    end

    def ministers
      item.role_appointments.collect {|a| a.person.content_id}
    end

    def related_statistical_data_sets
      item.statistical_data_sets.map(&:content_id)
    end

    def alternative_format_email
      item.alternative_format_provider.try(:alternative_format_contact_email)
    end
  end
end
