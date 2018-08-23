WorldLocation.all.each do |world_location|
  next if world_location.news_page_content_id.present?

  english_base_path = Whitehall.url_maker.world_location_news_index_path(
    world_location,
    locale: "en"
  )

  content_id_from_publishing_api = Services.publishing_api.lookup_content_id(
    base_path: english_base_path
  )

  world_location.update_column(
    :news_page_content_id,
    content_id_from_publishing_api
  )

  print "."
  $stdout.flush
end
