module Admin::EditionRoutesHelper
  include ActionDispatch::Routing::PolymorphicRoutes

  def admin_edition_path(edition, *args)
    polymorphic_path([:admin, edition], *args)
  end

  def admin_edition_url(edition, options = {})
    default_options = { host: Whitehall.admin_host }
    polymorphic_url([:admin, edition], default_options.merge(options))
  end

  def edit_admin_edition_path(edition, *args)
    polymorphic_path([:edit, :admin, edition], *args)
  end

  def edit_admin_corporate_information_page_url(edition, *args)
    polymorphic_url([:edit, :admin, edition.organisation, edition], *args)
  end

  def edit_admin_corporate_information_page_path(edition, *args)
    polymorphic_path([:edit, :admin, edition.organisation, edition], *args)
  end

  def admin_corporate_information_page_path(edition, *args)
    polymorphic_path([:admin, edition.organisation, edition], *args)
  end

  def admin_corporate_information_page_url(edition, *args)
    polymorphic_url([:admin, edition.organisation, edition], *args)
  end
end
