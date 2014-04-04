module Admin::EditionRoutesHelper
  EDITION_TYPES = [Policy, Publication, NewsArticle, Consultation, Speech,
                   WorldwidePriority, DetailedGuide, CaseStudy,
                   StatisticalDataSet, FatalityNotice, WorldLocationNewsArticle,
                   CorporateInformationPage]

  def self.edition_instance_route(name)
    EDITION_TYPES.each do |type|
      method_name = name.to_s.gsub("admin_edition", "admin_#{type.model_name.singular}")
      class_eval %{
        def #{method_name}(*args)
          #{name}(*args)
        end
      }
    end
  end

  edition_instance_route :admin_edition_supporting_pages_path
  edition_instance_route :admin_edition_editorial_remarks_path
  edition_instance_route :admin_edition_fact_check_requests_path

  def admin_edition_path(edition, *args)
    polymorphic_path([:admin, edition], *args)
  end

  def admin_edition_url(edition, *args)
    polymorphic_url([:admin, edition], *args)
  end

  def edit_admin_edition_path(edition, *args)
    polymorphic_path([:edit, :admin, edition], *args)
  end

  def edit_admin_corporate_information_page_path(edition, *args)
    polymorphic_path([:edit, :admin, edition.owning_organisation, edition], *args)
  end

  def admin_corporate_information_page_path(edition, *args)
    polymorphic_path([:admin, edition.owning_organisation, edition], *args)
  end

  def admin_corporate_information_pages_path(*args)
    # This is a fairly nasty hack that just happens to work.  We're relying on
    # the various admin_{things}_path helpers throughout the code, and we're
    # assuming that we can determine them from an edition's type; it's not
    # designed for the fact that corporate information pages are scoped to an
    # organisation.
    #
    # For editing an existing corporate information page, this isn't a problem,
    # because we can infer the owning organisation from the existing record;
    # when we want to create a new page, we don't have a nice way to tell the
    # helper which organisation we're trying to create a new page for. So we
    # rely on the controller having the `cip_owning_organisation` helper method
    # available, and blow up otherwise.
    polymorphic_path([:admin, cip_owning_organisation, CorporateInformationPage], *args)
  end
end
