require 'maxitest/autorun'
require 'mocha/setup'

require_relative '../../../config/environment'
require_relative '../../../lib/sync_checker/draft_topic_content_ids'

module SyncChecker
  class TestDraftTopicContentIds < Minitest::Test
    def test_it_returns_an_array_of_published_content_ids
      Services.expects(:publishing_api).returns(
        mock('client').tap do |client|
          client.expects(:get_linkables)
            .with(document_type: 'topic')
            .returns(
              [
                {
                  title: 'Draft 1',
                  content_id: 'e284845c-19f0-4130-8920-3888105b4433',
                  publication_state: 'draft',
                  base_path: '/topic/draft-1',
                  internal_name: 'Draft 1'
                },
                {
                  title: 'Published 1',
                  content_id: 'e3968207-2557-4f18-9f35-7d2ea328d2c6',
                  publication_state: 'published',
                  base_path: '/topic/published-1',
                  internal_name: 'Published 1'
                }
              ]
            )
        end
      )

      assert_equal ['e284845c-19f0-4130-8920-3888105b4433'], DraftTopicContentIds.fetch
      # call again tests that result is memoized
      assert_equal ['e284845c-19f0-4130-8920-3888105b4433'], DraftTopicContentIds.fetch
    end
  end
end
