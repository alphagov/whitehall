require "test_helper"

class PersonHelperTest < ActionView::TestCase
  include ApplicationHelper

  test "it disambiguates names with trailing spaces" do
    person_one = build(:person, forename: "Peter ", surname: "Jones")
    person_two = build(:person, forename: "Peter", surname: "Jones")
    person_one.stubs(:name_with_disambiguator).returns(
      "Peter Jones - Executive Director, Prisons"
    )
    person_two.stubs(:name_with_disambiguator).returns(
      "Peter Jones - Director, Overseas Territories"
    )

    Person.stubs(:includes).returns([person_one, person_two])

    expected_result = [
      ["Peter Jones - Executive Director, Prisons", person_one.id],
      ["Peter Jones - Director, Overseas Territories", person_two.id],
    ]
    assert_equal expected_result, disambiguated_people_names
  end
end
