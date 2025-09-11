module WorldLocationNewsHelper
  def world_location_news_path(world_location)
    "/world/#{world_location.slug}#{'/news' if world_location.world_location?}"
  end
end
