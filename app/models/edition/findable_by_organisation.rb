# This mixin should go away when we switch to a search backend for admin documents
module Edition::FindableByOrganisation
  def in_organisation(organisation)
    organisations = [*organisation]
    slugs = organisations.map(&:slug)
    where('exists (
             select * from edition_organisations eo_orgcheck
               join organisations orgcheck on eo_orgcheck.organisation_id=orgcheck.id
             where
               eo_orgcheck.edition_id=editions.id
             and orgcheck.slug in (?))', slugs)
  end
end
