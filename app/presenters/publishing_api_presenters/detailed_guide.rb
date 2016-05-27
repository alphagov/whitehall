require_relative "../publishing_api_presenters"

class PublishingApiPresenters::DetailedGuide < PublishingApiPresenters::Edition
  include PublishingApiPresenters::WithdrawingHelper
  include PublishingApiPresenters::PoliticalHelper # Detailed Guides need a government to publish successfully.

  def links
    extract_links([
      :organisations,
    ]).merge(
      related_guides: item.related_detailed_guide_content_ids,
      related_mainstream: item.related_mainstream
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
      related_mainstream_content: item.related_mainstream,
    ).merge(political_details)
      .tap do |json|
        json[:withdrawn_notice] = withdrawn_notice if item.withdrawn?
        json[:national_applicability] = item.national_applicability if item.nation_inapplicabilities.any?
      end
  end
end
