require 'gds_api/router'

module DataHygiene
  class DuplicateStatisticsAnnouncement
    attr_reader :logger

    def initialize(duplicate, logger=Rails.logger, noop=false)
      @duplicate = duplicate
      @logger = logger
      @noop = noop
    end

    def destroy_and_redirect_to(authoritative_announcement)
      register_redirect_to(authoritative_announcement)

      log "Destroying duplicate announcement with slug #{@duplicate.slug}"
      unless noop?
        @duplicate.destroy
      end
    end

  private

    def log(message)
      @logger.info message
    end

    def noop?
      @noop
    end

    def register_redirect_to(announcement)
      announcement_path = Whitehall.url_maker.statistics_announcement_path(announcement)

      log "Registering redirect: #{path} => #{announcement_path}"
      unless noop?
        router.add_redirect_route(path, :exact, announcement_path)
        router.commit_routes
      end
    end

    def path
      Whitehall.url_maker.statistics_announcement_path(@duplicate)
    end

    def router
      @router ||= GdsApi::Router.new(Plek.current.find('router-api'))
    end
  end
end
