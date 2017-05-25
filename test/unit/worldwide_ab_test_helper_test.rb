require 'test_helper'

class WorldwideAbHelperTest < ActiveSupport::TestCase
  def subject
    WorldwideAbTestHelper.new
  end

  test "content returns the parsed file " do
    result = subject.content
    assert result[:india].present?
  end

  test "has_content_for? returns true if the key is present" do
    assert subject.has_content_for?(:india)
  end

  test "has_content_for? returns true if the string key is present" do
    assert subject.has_content_for?("india")
  end

  test "has_content_for? returns false if the key is not present" do
    refute subject.has_content_for?("eggnogg")
  end

  test "content_for returns content for the key if present" do
    assert_not_nil subject.content_for("india")
  end

  test "content_for returns nil if the key is not present" do
    assert_nil subject.content_for("booyah")
  end

  test "location_for returns the first worldwide_location" do
    location = stub(slug: "turkey")
    org = stub(
      slug: "british-embassy-turkey",
      world_locations: [location]
    )

    assert_equal location, subject.location_for(org)
  end

  test "location_for returns hard coded location where present" do
    location = stub(slug: "turkey")
    hard_coded_location = stub(slug: "india")
    organisation = stub(
      slug: "british-deputy-high-commission-kolkata",
      world_locations: [location, hard_coded_location]
    )

    assert_equal hard_coded_location, subject.location_for(organisation)
  end

  test "is_under_test? returns true if location is first location" do
    location = stub(slug: "india")
    organisation = stub(
      slug: "british-deputy-high-commission-indialand",
      world_locations: [location]
    )

    assert subject.is_under_test?(organisation)
  end

  test "is_under_test? returns true if organisation slug is hard coded" do
    location = stub(slug: "embassy")
    other_location = stub(slug: "india")
    organisation = stub(
      slug: "british-deputy-high-commission-kolkata",
      world_locations: [location, other_location]
    )

    assert subject.is_under_test?(organisation)
  end

  test "is_under_test? returns false if the organisation isn't related to a location under test" do
    location = stub(slug: "germany")
    organisation = stub(
      slug: "embassy-in-germany",
      world_locations: [location]
    )

    refute subject.is_under_test?(organisation)
  end

  test "is_under_test? returns true if supplied with a location with content" do
    location = stub(slug: "india")
    assert subject.is_under_test?(location)
  end

  test "is_under_test? return false if the supplied with a location without content" do
    location = WorldLocation.new(slug: "germany")
    refute subject.is_under_test?(location)
  end
end
