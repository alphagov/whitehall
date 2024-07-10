selected_international_delegation_content_ids = %w[
  52e79dc1-2b32-4895-bbcd-c83a5e4803e4
  d8463190-7b80-4ef0-8f75-d36dfc3572a1
  30be2e13-6db3-487b-b97f-910feeb5e6a1
]

international_delegation_news_pages = WorldLocationNews.where(content_id: selected_international_delegation_content_ids).all
international_delegation_news_pages.each do |page|
  puts "Redirecting #{page.base_path} to #{page.world_location.base_path}"
  Whitehall::PublishingApi.publish_redirect_async(page.content_id, page.world_location.base_path)
end
