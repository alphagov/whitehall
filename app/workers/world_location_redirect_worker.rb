class WorldLocationRedirectWorker < WorkerBase
  def perform(world_location_id)
    world_location = WorldLocation.find_by(id: world_location_id)
    return if world_location.nil?

    base_path_prefix = "/world"

    en_slug = world_location.slug
    destination_base_path = File.join("", base_path_prefix, en_slug)
    content_id = world_location.content_id
    locales = world_location.available_locales - [:en]

    locales.each do |locale|
      fix_base_path(world_location, locale, en_slug)

      PublishingApiRedirectWorker.new.perform(
        content_id,
        destination_base_path,
        locale
      )
    end
  end

  def fix_base_path(world_location, locale, en_slug)
    presenter_class = PublishingApiPresenters.presenter_class_for(world_location)
    presenter = presenter_class.new(world_location)
    payload = presenter.content

    new_base_path = "/world/#{en_slug}.#{locale}"
    payload[:base_path] = new_base_path
    payload[:routes] = [{ path: new_base_path, type: "exact" }]
    payload[:locale] = locale

    Services.publishing_api.put_content(world_location.content_id, payload)
    Services.publishing_api.publish(world_location.content_id, "republish", locale: locale)
  end
end
