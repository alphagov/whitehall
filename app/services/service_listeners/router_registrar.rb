module ServiceListeners
  class RouterRegistrar
    def initialize(edition)
      @edition = edition
    end

    def register!
      if @edition.is_a? DetailedGuide
        RouterAddRouteWorker.perform_async(url)
      end
    end

    def unregister!
      if @edition.is_a? DetailedGuide
        RouterDeleteRouteWorker.perform_async(url)
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
