require "test_helper"

class Document::FactCheckableTest < ActiveSupport::TestCase
  test "#destroy should also remove the fact check requests" do
    document = create(:draft_policy)
    fact_check_request = create(:fact_check_request, document: document)
    document.destroy
    refute FactCheckRequest.find_by_id(fact_check_request.id)
  end
end
