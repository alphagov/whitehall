require "test_helper"

class FlexiblePageTest < ActiveSupport::TestCase
  test "does not require some of the standard edition fields" do
    page = FlexiblePage.new
    assert_not page.summary_required?
    assert_not page.body_required?
    assert_not page.can_set_previously_published?
    assert_not page.previously_published
  end
end
