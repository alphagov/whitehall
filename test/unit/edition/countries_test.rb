require "test_helper"

class Edition::CountriesTest < ActiveSupport::TestCase
  test "#destroy should also remove the relationship" do
    edition = create(:draft_policy, countries: [create(:country)])
    relation = edition.edition_countries.first
    edition.destroy
    refute EditionCountry.find_by_id(relation.id)
  end
end
