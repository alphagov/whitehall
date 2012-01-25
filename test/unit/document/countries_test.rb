require "test_helper"

class Document::CountriesTest < ActiveSupport::TestCase
  test "#destroy should also remove the relationship" do
    document = create(:draft_policy, countries: [create(:country)])
    relation = document.document_countries.first
    document.destroy
    refute DocumentCountry.find_by_id(relation.id)
  end
end
