organisation = Organisation.find_by(slug: 'appointed-person-for-england-and-wales-under-the-proceeds-of-crime-act-2002')
if organisation.present?
  # This association does have a dependent destroy, but if there are documents
  # we probably need to do some more 410/404 stuff
  raise "Can't remove #{organisation.name} - it has editions" if organisation.editions.count.positive?

  # This association doesn't have a dependent option, but isn't simple enough
  # to just destroy them all so we halt execution
  raise "Can't remove #{organisation.name} - it has groups" if organisation.groups.count.positive?

  # These associations don't have a dependent option, but are simple enough
  # that we can just destroy_all them and continue
  organisation.organisation_roles.destroy_all
  organisation.financial_reports.destroy_all
  organisation.offsite_links.destroy_all
  organisation.featured_policies.destroy_all
  organisation.promotional_features.destroy_all

  Whitehall::SearchIndex.delete(organisation)
  organisation.destroy
end
