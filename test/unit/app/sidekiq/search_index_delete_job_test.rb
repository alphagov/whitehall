require "test_helper"

class SearchIndexDeleteJobTest < ActiveSupport::TestCase
  test "#perform deletes the instance from its index" do
    index = mock("search_index")
    index.expects(:delete).with("woo")
    Whitehall::SearchIndex.expects(:for).with(:government, anything).returns(index)

    SearchIndexDeleteJob.new.perform("woo", "government")
  end
end
