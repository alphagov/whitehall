require "test_helper"
require "rake"

class RemoveAccessLimitingTest < ActiveSupport::TestCase
  teardown do
    Rake::Task["remove_access_limiting"].reenable
  end

  test "sets access limited to false for selected edition" do
    edition = create(:draft_edition, :access_limited)

    assert_output(/Access limited successfully set to false for edition of ID #{edition.id}./) { Rake.application.invoke_task("remove_access_limiting[#{edition.id}]") }

    edition.reload
    assert_equal false, edition.access_limited
  end

  test "raises error if edition cannot be found" do
    assert_raises(StandardError, match: "Cannot find edition of ID 12345.") do
      Rake.application.invoke_task("remove_access_limiting[12345]")
    end
  end
end
