module Edition::TaggableOrganisations
  extend ActiveSupport::Concern

  def can_be_tagged_to_taxonomy?
    organisations_content_ids = organisations.map(&:content_id)

    organisations_in_tagging_beta?(organisations_content_ids)
  end

private

  def organisations_in_tagging_beta?(org_content_ids)
    return false if org_content_ids.empty?

    organisations_in_tagging_beta = Whitehall.organisations_in_tagging_beta

    org_content_ids.any? do |id|
      organisations_in_tagging_beta.include?(id)
    end
  end
end
