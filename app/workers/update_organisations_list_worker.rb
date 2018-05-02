class UpdateOrganisationsListWorker < WorkerBase
  def perform
    PublishStaticPages.new.patch_links(
      "fde62e52-dfb6-42ae-b336-2c4faf068101", # content_id for /government/organisations
      links: links
    )
  end

private

  def links
    {
      ordered_executive_offices: organisation_content_ids(:executive_offices),
      ordered_ministerial_departments: organisation_content_ids(:ministerial_departments),
      ordered_non_ministerial_departments: organisation_content_ids(:non_ministerial_departments),
      ordered_agencies_and_other_public_bodies: organisation_content_ids(:agencies_and_government_bodies),
      ordered_high_profile_groups: organisation_content_ids(:high_profile_groups),
      ordered_public_corporations: organisation_content_ids(:public_corporations),
      ordered_devolved_administrations: organisation_content_ids(:devolved_administrations)
    }
  end

  def organisation_content_ids(organisation_type_key)
    presented_organisations.send(organisation_type_key).map(&:content_id)
  end

  def presented_organisations
    @presented_organisations ||= OrganisationsIndexPresenter.new(all_organisations)
  end

  def all_organisations
    @all_organisations ||= Organisation.excluding_courts_and_tribunals.listable.ordered_by_name_ignoring_prefix
  end
end
