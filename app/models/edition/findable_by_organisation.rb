# This mixin should go away when we switch to a search backend for admin documents
module Edition::FindableByOrganisation
  def in_organisation(organisation)
    organisation_ids = Array(organisation).map(&:id)

    where('exists (SELECT * FROM edition_organisations eo_orgcheck
                   WHERE eo_orgcheck.edition_id = editions.id
                   AND eo_orgcheck.organisation_id IN (:ids))',
          ids: organisation_ids)
  end
end
