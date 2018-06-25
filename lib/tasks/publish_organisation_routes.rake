namespace :router do
  desc "Switch organisations to be rendered from collections. This should be
  followed by a republish of organisations, but this takes several hours so is
  a little unwieldy"
  task render_orgs_from_collections: :environment do
    set_routes(Whitehall::RenderingApp::COLLECTIONS_FRONTEND)
  end

  def set_routes(rendering_app)
    router_api = GdsApi::Router.new(Plek.find('router-api'))

    Organisation.all.order(:slug).each do |org|
      set_route_for_org(router_api, org, rendering_app)
    end

    router_api.commit_routes
  end

  def set_route_for_org(router_api, organisation, rendering_app)
    path = Whitehall.url_maker.polymorphic_path(organisation)

    unless path.start_with? "/court"
      puts "adding route for #{path} to #{rendering_app}"
      router_api.add_route(path, "exact", rendering_app)

      if organisation.translations.count > 1
        puts "adding route for #{path}.cy to #{rendering_app}"
        router_api.add_route("#{path}.cy", "exact", rendering_app)
      end
    end
  end

  desc "Switch organisations to be rendered from whitehall. The presenter would
  need to be fixed as well if this is done on production, followed by a republish
  of organisations, but this takes several hours so is a little unwieldy"
  task render_orgs_from_whitehall: :environment do
    set_routes(Whitehall::RenderingApp::WHITEHALL_FRONTEND)
  end
end
