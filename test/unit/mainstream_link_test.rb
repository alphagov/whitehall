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

  test 'only_the_initial_set retreives the first 5 by default' do
    6.times { create(:mainstream_link) }

    assert_equal 5, MainstreamLink.only_the_initial_set.size
    assert_equal 3, MainstreamLink.only_the_initial_set(3).size
  end
end
