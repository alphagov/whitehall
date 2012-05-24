require "test_helper"

class Edition::FactCheckableTest < ActiveSupport::TestCase
  test "#destroy should also remove the fact check requests" do
    edition = create(:draft_policy)
    fact_check_request = create(:fact_check_request, edition: edition)
    edition.destroy
    refute FactCheckRequest.find_by_id(fact_check_request.id)
  end
end
