require_relative "../publishing_api_presenters"

class PublishingApiPresenters::DetailedGuide < PublishingApiPresenters::Edition
  include PublishingApiPresenters::WithdrawingHelper
  include PublishingApiPresenters::PoliticalHelper # Detailed Guides need a government to publish successfully.
  include PublishingApiPresenters::ApplicabilityHelper

  def links
    extract_links([
      :organisations,
    ]).merge(
      related_guides: related_guides,
      related_mainstream: related_mainstream
    )
  end

private

  def schema_name
    "detailed_guide"
  end

  def details
    super.merge(
      body: body,
      change_history: item.change_history.as_json,
      emphasised_organisations: item.lead_organisations.map(&:content_id),
      first_public_at: first_public_at,
      related_mainstream_content: related_mainstream,
    ).merge(political_details)
      .tap do |json|
        json[:withdrawn_notice] = withdrawn_notice if item.withdrawn?
        json[:national_applicability] = national_applicability if item.nation_inapplicabilities.any?
      end
  end

  def related_guides
    item.related_detailed_guide_content_ids
  end

  def related_mainstream
    base_paths = []
    base_paths.push(item.related_mainstream_base_path)
    base_paths.push(item.additional_related_mainstream_base_path)
    base_paths.compact!

    if base_paths.any?
      Whitehall.publishing_api_v2_client
        .lookup_content_ids(base_paths: base_paths)
        .values
        .compact
    else
      []
    end
  end
end
