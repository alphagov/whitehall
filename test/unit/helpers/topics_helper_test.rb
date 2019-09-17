require "test_helper"

class TopicsHelperTest < ActionView::TestCase
  test "classification_contents_breakdown generates a sentence that ends with the number of published detailed guides belonging to the classification" do
    t = create(:topic)

    assert_match(/0 published detailed guides/, classification_contents_breakdown(t))

    create(:published_detailed_guide, topics: [t])
    assert_match(/1 published detailed guide/, classification_contents_breakdown(t))

    create(:published_detailed_guide, topics: [t])
    assert_match(/2 published detailed guides/, classification_contents_breakdown(t))
  end
end
