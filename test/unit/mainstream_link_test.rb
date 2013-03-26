require "test_helper"

class MainstreamLinkTest < ActiveSupport::TestCase
  test "should not be valid without a url" do
    link = build(:mainstream_link, url: nil)
    refute link.valid?
  end

  test "should not be valid without a title" do
    link = build(:mainstream_link, title: nil)
    refute link.valid?
  end

  test "should not be valid with a url that doesn't start with http" do
    link = build(:mainstream_link, url: "not a link")
    refute link.valid?
  end

  test 'only_the_initial_set retreives the first 5 in creation order' do
    link_1 = create(:mainstream_link, created_at: 2.days.ago)
    link_2 = create(:mainstream_link, created_at: 12.days.ago)
    link_3 = create(:mainstream_link, created_at: 1.hour.ago)
    link_4 = create(:mainstream_link, created_at: 2.hours.ago)
    link_5 = create(:mainstream_link, created_at: 20.minutes.ago)
    link_6 = create(:mainstream_link, created_at: 2.years.ago)

    assert_equal [link_6, link_2, link_1, link_4, link_3], MainstreamLink.only_the_initial_set
  end
end
