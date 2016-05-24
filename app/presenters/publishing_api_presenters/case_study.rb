require_relative "../publishing_api_presenters"

class PublishingApiPresenters::CaseStudy < PublishingApiPresenters::Edition
  include PublishingApiPresenters::WithdrawingHelper

  def links
    extract_links([
      :document_collections,
      :organisations,
      :related_policies,
      :topics,
      :world_locations,
      :worldwide_organisations,
    ])
  end

private

  def schema_name
    "case_study"
  end

  def details
    super.merge({
      body: body,
      format_display_type: item.display_type_key,
      first_public_at: first_public_at,
      change_history: item.change_history.as_json,
      emphasised_organisations: item.lead_organisations.map(&:content_id),
    }).tap do |json|
      json[:image] = image_details if image_available?
      json[:withdrawn_notice] = withdrawn_notice if item.withdrawn?
    end
  end

  def image_details
    {
      url: Whitehall.public_asset_host + presented_case_study.lead_image_path,
      alt_text: presented_case_study.lead_image_alt_text,
      caption: presented_case_study.lead_image_caption,
    }
  end

  def image_available?
    item.images.any? || emphasised_organisation_default_image_available?
  end

  def emphasised_organisation_default_image_available?
    item.lead_organisations.first.default_news_image.present?
  end

  def presented_case_study
    CaseStudyPresenter.new(item)
  end

  def policy_content_ids
    item.policy_content_ids
  end
end
