class PublishingApiPresenters::CaseStudy < PublishingApiPresenters::Edition
  def as_json
    super.merge(
      format: "case_study",
      rendering_app: edition.rendering_app,
      links: links
    )
  end

private

  def links
    {
      lead_organisations: edition.lead_organisations.map(&:content_id),
      related_policies: policy_content_ids,
      supporting_organisations: edition.supporting_organisations.map(&:content_id),
      document_collections: edition.published_document_collections.map(&:content_id),
      world_locations: edition.world_locations.map(&:content_id),
      worldwide_organisations: edition.worldwide_organisations.map(&:content_id),
      worldwide_priorities: edition.worldwide_priorities.map(&:content_id),
    }
  end

  def details
    super.merge({
      body: body,
      format_display_type: edition.display_type_key,
      first_public_at: edition.first_public_at,
      change_history: edition.change_history.as_json,
    }).tap do |json|
      json[:image] = image_details if image_available?
      json[:archive_notice] = archive_notice if edition.archived?
    end
  end

  def image_details
    {
      url: Whitehall.asset_root + presented_case_study.lead_image_path,
      alt_text: presented_case_study.lead_image_alt_text,
      caption: presented_case_study.lead_image_caption,
    }
  end

  def archive_notice
    {
      explanation: unpublishing_explanation,
      archived_at: edition.updated_at
    }
  end

  def body
    Whitehall::EditionGovspeakRenderer.new(edition).body
  end

  def unpublishing_explanation
    Whitehall::EditionGovspeakRenderer.new(edition).unpublishing_explanation
  end

  def image_available?
    edition.images.any? || lead_organisation_default_image_available?
  end

  def lead_organisation_default_image_available?
    edition.lead_organisations.first.default_news_image.present?
  end

  def presented_case_study
    CaseStudyPresenter.new(edition)
  end

  def policy_content_ids
    edition.policy_content_ids
  end
end
