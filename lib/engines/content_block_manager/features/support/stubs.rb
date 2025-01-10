Before do
  stub_publishing_api_has_embedded_content_for_any_content_id(total: 0, results: [], order: ContentBlockManager::HostContentItem::DEFAULT_ORDER)
end

Before("@disable_sidekiq") do
  Sidekiq::Testing.fake!
end

Before("@enable_sidekiq") do
  Sidekiq::Testing.disable!
  Sidekiq::ScheduledSet.new.map(&:delete)
end
