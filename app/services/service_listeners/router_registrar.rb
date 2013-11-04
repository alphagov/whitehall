require 'plek'
require 'gds_api/router'

module ServiceListeners
  class RouterRegistrar
    def initialize(edition)
      @edition = edition
      @router_api = GdsApi::Router.new(Plek.current.find('router-api'))
    end

    def register!
      if @edition.is_a? DetailedGuide
        @router_api.add_route(url, "exact", "whitehall-frontend")
      end
    end

    def unregister!
      if @edition.is_a? DetailedGuide
        @router_api.delete_route(url, "exact", "whitehall-frontend")
      end
    end

    private

    def url_maker
      @url_maker ||= Whitehall::UrlMaker.new(host: Whitehall.public_host, protocol: Whitehall.public_protocol)
    end

    def url
      url_maker.document_path(@edition)
    end
  end
end
