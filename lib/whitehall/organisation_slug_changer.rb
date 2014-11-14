require 'gds_api/router'

class Whitehall::OrganisationSlugChanger
  attr_reader :organisation, :old_slug, :new_slug, :logger, :router

  def initialize(organisation, new_slug, logger: nil, router: nil)
    @organisation = organisation
    @old_slug = organisation.slug
    @new_slug = new_slug
    @logger = logger || Logger.new(nil)
    @router = router || default_router
  end

  def call
    logger.info "Changing org slug from #{old_slug} to #{new_slug}"

    # Remove document at old slug from search
    organisation.remove_from_search_index

    Organisation.transaction do
      organisation.slug = new_slug
      organisation.save! # saving also indexes at new slug

      User.where(:organisation_slug => old_slug).update_all(:organisation_slug => new_slug)
    end

    logger.info "Creating redirect for old org URL in router"
    router.add_redirect_route("/government/organisations/#{old_slug}",
                              "exact",
                              "/government/organisations/#{new_slug}")

    logger.info "Re-registering #{new_slug} published editions in search and panopticon"
    organisation.editions.published.find_each do |edition|
      ServiceListeners::SearchIndexer.new(edition).index!
      ServiceListeners::PanopticonRegistrar.new(edition).register!
    end
  end

  def default_router
    GdsApi::Router.new(Plek.current.find('router-api'))
  end
end
