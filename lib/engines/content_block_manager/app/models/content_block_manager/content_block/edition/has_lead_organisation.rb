module ContentBlockManager
  module ContentBlock::Edition::HasLeadOrganisation
    extend ActiveSupport::Concern

    included do
      has_one :edition_organisation, foreign_key: :content_block_edition_id,
                                     dependent: :destroy,
                                     class_name: "ContentBlockManager::ContentBlock::EditionOrganisation"
      has_one :organisation, through: :edition_organisation

      validates_with ContentBlockManager::OrganisationValidator
    end

    def organisation_id=(organisation_id)
      if organisation_id.empty?
        self.edition_organisation = nil
      else
        edition_organisation = build_edition_organisation
        edition_organisation.organisation_id = organisation_id
      end
    end

    def lead_organisation
      organisation
    end
  end
end
