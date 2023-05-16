module DocumentControllerTestHelpers
  extend ActiveSupport::Concern

private

  def controller_attributes_for(edition_type, attributes = {})
    if edition_type.to_s.classify.constantize.new.can_be_related_to_organisations?
      attributes = attributes.merge(
        lead_organisation_ids: [(Organisation.first || create(:organisation)).id],
      )
    end

    attributes_for(edition_type, attributes).except(:attachments)
  end
end
