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

      User.where(organisation_slug: old_slug).update_all(organisation_slug: new_slug)
    end

    logger.info "Creating redirect for old org URL in router"
    logger.info "   /government/organisations/#{old_slug} => /government/organisations/#{new_slug}"
    router_data_csv_lines = "/government/organisations/#{old_slug},/government/organisations/#{new_slug}\n"
    router.add_redirect_route("/government/organisations/#{old_slug}",
                              "exact",
                              "/government/organisations/#{new_slug}")

    logger.info "Creating redirect for old org CIP pages (if any) in router"
    organisation.corporate_information_pages.published.find_each do |cip|
      new_path = Whitehall.url_maker.public_document_path(cip)
      old_path = new_path.sub(%r{\A/government/organisations/#{new_slug}/}, "/government/organisations/#{old_slug}/")
      logger.info "   #{old_path} => #{new_path}"
      router_data_csv_lines << "#{old_path},#{new_path}\n"
      router.add_redirect_route(old_path, "exact", new_path)
    end

    router.commit_routes

    logger.info "Re-registering #{new_slug} published editions in search"
    organisation.editions.published.find_each do |edition|
      ServiceListeners::SearchIndexer.new(edition).index!
    end

    logger.info "Re-registering #{new_slug} statistics announcements without publications in search"
    organisation.statistics_announcements.without_published_publication.find_each do |statistics_announcement|
      ServiceListeners::SearchIndexer.new(statistics_announcement).index!
    end

    logger.info "Complete.\n\nThe following entries should be added to router-data:\n"
    logger.info router_data_csv_lines
  end

  def default_router
    GdsApi::Router.new(Plek.current.find('router-api'))
  end
end
