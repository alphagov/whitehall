# This mixin should go away when we switch to a search backend for admin documents
module Edition::FindableByOrganisation
  def in_organisation(organisation)
    organisation_ids = Array(organisation).map(&:id)

    where('(editions.type <> "SupportingPage"
            AND exists (SELECT * FROM edition_organisations eo_orgcheck
                        WHERE eo_orgcheck.edition_id = editions.id
                        AND eo_orgcheck.organisation_id IN (:ids)))
           OR
           (editions.type = "SupportingPage"
            AND exists (SELECT * FROM edition_organisations eo_orgcheck
                        JOIN editions policies_orgcheck ON eo_orgcheck.edition_id = policies_orgcheck.id
                        JOIN edition_relations er_orgcheck ON policies_orgcheck.document_id = er_orgcheck.document_id
                        WHERE er_orgcheck.edition_id = editions.id
                        AND eo_orgcheck.organisation_id IN (:ids)))',
          ids: organisation_ids)
  end
end
