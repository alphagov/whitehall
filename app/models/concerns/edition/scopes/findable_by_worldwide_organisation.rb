module Edition::Scopes::FindableByWorldwideOrganisation
  extend ActiveSupport::Concern

  included do
    scope :in_worldwide_organisation, lambda { |worldwide_organisation|
      worldwide_organisation_ids = Array(worldwide_organisation).map(&:id)

      where(
        'exists (SELECT * FROM edition_worldwide_organisations ewo_orgcheck
                          WHERE ewo_orgcheck.edition_id = editions.id
                          AND ewo_orgcheck.worldwide_organisation_id IN (:ids))',
        ids: worldwide_organisation_ids,
      )
    }
  end
end
