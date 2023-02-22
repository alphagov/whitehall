require "test_helper"

class WorldLocationNewsTest < ActiveSupport::TestCase
  test "public_path returns the correct path" do
    world_location = build(:world_location, slug: "foo")
    world_location_news = create(:world_location_news, world_location:)
    assert_equal "/world/foo/news", world_location_news.public_path(locale: :en)
  end

  test "public_path returns the correct path with options" do
    world_location = build(:world_location, slug: "foo")
    world_location_news = create(:world_location_news, world_location:)
    assert_equal "/world/foo/news?cachebust=123", world_location_news.public_path({ cachebust: "123" }, locale: :en)
  end

  test "public_url returns the correct path" do
    world_location = build(:world_location, slug: "foo")
    world_location_news = create(:world_location_news, world_location:)
    assert_equal "https://www.test.gov.uk/world/foo/news", world_location_news.public_url(locale: :en)
  end

  test "public_url returns the correct path with options" do
    world_location = build(:world_location, slug: "foo")
    world_location_news = create(:world_location_news, world_location:)
    assert_equal "https://www.test.gov.uk/world/foo/news?cachebust=123", world_location_news.public_url({ cachebust: "123" }, locale: :en)
  end
end
