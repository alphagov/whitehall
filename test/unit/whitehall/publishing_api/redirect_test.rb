require "test_helper"

class Whitehall::PublishingApi::RedirectTest < ActiveSupport::TestCase
  setup do
    @base_path = "/government/thong"
    @redirects = [
      { path: @base_path, type: "exact", destination: "/government/thing" },
    ]
    @redirect = Whitehall::PublishingApi::Redirect.new(@base_path, @redirects)
    @output_hash = @redirect.as_json
  end

  test "generates a valid redirect content item" do
    assert_valid_against_publisher_schema(@output_hash, "redirect")
  end

  test "#base_path returns the base_path" do
    assert_equal @base_path, @redirect.base_path
  end

  test "sets the publishing_app to 'whitehall'" do
    assert_equal Whitehall::PublishingApp::WHITEHALL, @output_hash[:publishing_app]
  end

  test "sets the redirects as provided" do
    assert_equal @redirects, @output_hash[:redirects]
  end
end
