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

  def edit_admin_corporate_information_page_url(edition, *args)
    polymorphic_url([:edit, :admin, edition.owning_organisation, edition], *args)
  end

  def edit_admin_corporate_information_page_path(edition, *args)
    polymorphic_path([:edit, :admin, edition.owning_organisation, edition], *args)
  end

  def admin_corporate_information_page_path(edition, *args)
    polymorphic_path([:admin, edition.owning_organisation, edition], *args)
  end

  def admin_corporate_information_page_url(edition, *args)
    polymorphic_url([:admin, edition.owning_organisation, edition], *args)
  end
end
