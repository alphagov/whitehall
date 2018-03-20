require 'test_helper'

class Taxonomy::RedisCacheAdapterTest < ActiveSupport::TestCase
  def subject
    Taxonomy::RedisCacheAdapter.new(
      redis_client: redis_client,
      adapter: publishing_api_adapter
    )
  end

  def redis_client
    @client ||= stub
  end

  def publishing_api_adapter
    @adapter ||= stub
  end

  test "#rebuild_caches" do
    published_taxons = { 'baz' => 'qux' }
    publishing_api_adapter.stubs(:taxon_data).returns(published_taxons)
    redis_client.expects(:set).with("govuk_taxonomy_taxons", JSON.dump(published_taxons))
    subject.rebuild_caches
  end
end
