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
    draft_taxons = { 'foo' => 'bar' }
    published_taxons = { 'baz' => 'qux' }
    publishing_api_adapter.stubs(:draft_taxon_data).returns(draft_taxons)
    publishing_api_adapter.stubs(:published_taxon_data).returns(published_taxons)
    redis_client.expects(:set).with("govuk_taxonomy_draft_taxons", JSON.dump(draft_taxons))
    redis_client.expects(:set).with("govuk_taxonomy_published_taxons", JSON.dump(published_taxons))
    subject.rebuild_caches
  end
end
