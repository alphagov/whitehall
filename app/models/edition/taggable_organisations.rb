module Edition::TaggableOrganisations
  extend ActiveSupport::Concern

  def can_be_tagged_to_taxonomy?
    organisations_content_ids = organisations.map(&:content_id)

    organisations_in_education_tagging_beta?(organisations_content_ids)
  end

private

  def organisations_in_education_tagging_beta?(org_content_ids)
    (org_content_ids & Whitehall.organisations_in_tagging_beta["education_related"]).present?
  end
end
