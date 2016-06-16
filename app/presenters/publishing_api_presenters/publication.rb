require_relative "../publishing_api_presenters"

class PublishingApiPresenters::Publication < PublishingApiPresenters::Edition
  include PublishingApiPresenters::WithdrawingHelper
  include PublishingApiPresenters::PoliticalHelper
  include PublishingApiPresenters::ApplicabilityHelper

  def links
    extract_links([
      :organisations,
      :document_collections,
      :world_locations
    ]).merge(
      ministers: ministers,
      related_statistical_data_sets: item.statistical_data_set_ids,
      topical_events: topical_events
    )
  end

private

  def schema_name
    "publication"
  end

  def details
    super.merge({
      body: body,
      documents: documents,
      first_public_at: first_public_at,
      change_history: item.change_history.as_json,
      emphasised_organisations: item.lead_organisations.map(&:content_id)
    }).merge(political_details)
      .tap do |json|
        json[:withdrawn_notice] = withdrawn_notice if item.withdrawn?
        json[:national_applicability] = national_applicability if item.nation_inapplicabilities.any?
      end
  end

  def documents
    return [] unless item.attachments.any?
    Whitehall::GovspeakRenderer.new.block_attachments(item.attachments)
  end

  def ministers
    item.role_appointments
      .collect {|a| a.person.content_id}
  end

  def topical_events
    ::TopicalEvent
      .joins(:classification_memberships)
      .where(classification_memberships: {edition_id: item.id})
      .pluck(:content_id)
  end
end
