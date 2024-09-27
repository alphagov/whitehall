require "test_helper"

class Taxonomy::RedisCacheAdapterTest < ActiveSupport::TestCase
  def subject
    Taxonomy::RedisCacheAdapter.new(
      redis_client:,
      adapter: publishing_api_adapter,
    )
  end

  def redis_client
    @redis_client ||= stub
  end

  def publishing_api_adapter
    @publishing_api_adapter ||= stub
  end

  test "uses TAXONOMY_CACHE_REDIS_URL value for Redis Client if it has been set" do
    mock_env("TAXONOMY_CACHE_REDIS_URL" => "redis://taxonomy-cache") do
      Redis.expects(:new).with(
        url: "redis://taxonomy-cache",
        reconnect_attempts: 4,
        reconnect_delay: 15,
        reconnect_delay_max: 60,
      )

      Taxonomy::RedisCacheAdapter.new(adapter: publishing_api_adapter)
    end
  end

  test "uses the default REDIS_URL for Redis Client if TAXONOMY_CACHE_REDIS_URL has not been set" do
    mock_env({
      "TAXONOMY_CACHE_REDIS_URL" => nil,
      "REDIS_URL" => "redis://my-redis-url",
    }) do
      Redis.expects(:new).with(
        url: "redis://my-redis-url",
        reconnect_attempts: 4,
        reconnect_delay: 15,
        reconnect_delay_max: 60,
      )

      Taxonomy::RedisCacheAdapter.new(adapter: publishing_api_adapter)
    end
  end

  test "#rebuild_caches" do
    published_taxons = { "baz" => "qux" }
    publishing_api_adapter.stubs(:taxon_data).returns(published_taxons)
    redis_client.expects(:set).with("topic_taxonomy_taxons", JSON.dump(published_taxons))
    subject.rebuild_caches
  end

  test "#rebuild_world_taxon_caches" do
    published_world_taxons = { "baz" => "qux" }
    publishing_api_adapter.stubs(:world_taxon_data).returns(published_world_taxons)
    redis_client.expects(:set).with("world_taxonomy_taxons", JSON.dump(published_world_taxons))
    subject.rebuild_world_taxon_caches
  end
end
