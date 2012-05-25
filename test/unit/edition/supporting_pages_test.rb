require "test_helper"

class Edition::SupportingPagesTest < ActiveSupport::TestCase
  test "#destroy should also remove the supporting pages" do
    edition = create(:draft_policy)
    supporting_page = create(:supporting_page, edition: edition)
    edition.destroy
    refute SupportingPage.find_by_id(supporting_page.id)
  end

  test "#destroy should also remove the supporting pages for published editions" do
    edition = create(:published_policy)
    supporting_page = create(:supporting_page, edition: edition)
    edition.destroy
    refute SupportingPage.find_by_id(supporting_page.id)
  end
end
