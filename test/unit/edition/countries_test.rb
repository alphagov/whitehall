require "test_helper"

class Edition::CountriesTest < ActiveSupport::TestCase
  test "#destroy should also remove the relationship" do
    document = create(:draft_policy, countries: [create(:country)])
    relation = document.edition_countries.first
    document.destroy
    refute EditionCountry.find_by_id(relation.id)
  end
end
