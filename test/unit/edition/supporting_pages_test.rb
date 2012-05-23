require "test_helper"

class Edition::SupportingPagesTest < ActiveSupport::TestCase
  test "#destroy should also remove the supporting pages" do
    document = create(:draft_policy)
    supporting_page = create(:supporting_page, edition: document)
    document.destroy
    refute SupportingPage.find_by_id(supporting_page.id)
  end

  test "#destroy should also remove the supporting pages for published documents" do
    document = create(:published_policy)
    supporting_page = create(:supporting_page, edition: document)
    document.destroy
    refute SupportingPage.find_by_id(supporting_page.id)
  end
end
