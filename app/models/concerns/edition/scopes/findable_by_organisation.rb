module Edition::Scopes::FindableByOrganisation
  extend ActiveSupport::Concern

  included do
    scope :in_organisation, lambda { |organisation|
      organisation_ids = Array(organisation).map(&:id)

      where(
        'exists (SELECT * FROM edition_organisations eo_orgcheck
                        WHERE eo_orgcheck.edition_id = editions.id
                        AND eo_orgcheck.organisation_id IN (:ids))',
        ids: organisation_ids,
      )
    }
  end
end
