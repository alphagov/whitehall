module ContentBlockManager
  module ContentBlock::Document::Scopes::SearchableByLeadOrganisation
    extend ActiveSupport::Concern

    included do
      scope :with_lead_organisation,
            lambda { |id|
              joins(latest_edition: :edition_organisation).where("content_block_edition_organisations.organisation_id = :id", id:)
            }
    end
  end
end
