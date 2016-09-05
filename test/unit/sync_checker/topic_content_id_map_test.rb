require 'maxitest/autorun'
require 'mocha/setup'

require_relative '../../../config/environment'
require_relative "../../../lib/sync_checker/topic_content_id_map"

module SyncChecker
  class TestTopicContentIdMap < Minitest::Test
    def test_it_requests_all_specialist_sector_base_paths
      SpecialistSector.expects(:pluck).with(:tag).returns(%w(test_one test_two))
      Whitehall.expects(:publishing_api_v2_client).returns(
        mock("client").tap do |client|
          client.expects(:lookup_content_ids).with(
            base_paths: %w(
              /topic/test_one
              /topic/test_two
            )
          ).returns("booyah")
        end
      )
      assert_equal "booyah", TopicContentIdMap.fetch
      #call again tests that result is memoized
      assert_equal "booyah", TopicContentIdMap.fetch
    end
  end
end
