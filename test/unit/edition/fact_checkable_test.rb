require "test_helper"

class Edition::FactCheckableTest < ActiveSupport::TestCase
  test "#destroy should also remove the fact check requests" do
    edition = create(:draft_publication)
    fact_check_request = create(:fact_check_request, edition: edition)
    edition.destroy
    refute FactCheckRequest.find_by(id: fact_check_request.id)
  end

  test "should list all completed fact check requests from all editions, newest first" do
    begin
      time_0 = Time.zone.now
      user = create(:user)
      old_edition = create(:published_publication)
      Timecop.freeze time_0
      old_complete_fcr = create(:fact_check_request, edition: old_edition, comments: "Stuff")
      Timecop.freeze time_0 + 1
      old_incomplete_fcr = create(:fact_check_request, edition: old_edition)
      new_edition = old_edition.create_draft(user)
      Timecop.freeze time_0 + 2
      new_complete_fcr = create(:fact_check_request, edition: new_edition, comments: "Stuff")

      expected = [new_complete_fcr, old_complete_fcr]
      assert_equal expected, new_edition.all_completed_fact_check_requests
    ensure
      Timecop.return
    end
  end
end
