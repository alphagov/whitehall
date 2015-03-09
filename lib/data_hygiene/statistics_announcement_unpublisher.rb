require 'gds_api/router'

module DataHygiene
  class StatisticsAnnouncementUnpublisher
    def initialize(announcement_slug:, logger:)
      @announcement_slug = announcement_slug
      @logger = logger
    end

    def call
      if announcement
        register_gone_route
        destroy_announcement
      else
        logger.error(
          %(Could not find StatisticsAnnouncement with slug "#{announcement_slug}")
        )
      end
    end

  private
    attr_reader :announcement_slug, :logger

    def announcement
      @announcement ||= StatisticsAnnouncement.find_by(slug: announcement_slug)
    end

    def register_gone_route
      route = announcement.public_path

      logger.info(%(Registering GONE route for "#{route}"))

      router_api.add_gone_route(route, :exact, commit: true)
    end

    def destroy_announcement
      logger.info(
        %(Deleting StatisticsAnnouncement with slug "#{announcement_slug}")
      )

      announcement.destroy
    end

    def router_api
      @router_api ||= GdsApi::Router.new(Plek.new.find("router-api"))
    end
  end
end
