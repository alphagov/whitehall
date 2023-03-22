require "test_helper"

class WorldLocationTest < ActiveSupport::TestCase
  should_protect_against_xss_and_content_attacks_on :world_location, :name

  test "should be invalid without a name" do
    world_location = build(:world_location, name: nil)
    assert_not world_location.valid?
  end

  test "should be invalid without a world location type" do
    world_location = build(:world_location, world_location_type: nil)
    assert_not world_location.valid?
  end

  test "should set a slug from the name" do
    world_location = create(:world_location, name: "Costa Rica")
    assert_equal "costa-rica", world_location.slug
  end

  test "should not change the slug when the name is changed" do
    world_location = create(:world_location, name: "New Holland")
    world_location.update!(name: "Australia")
    assert_equal "new-holland", world_location.slug
  end

  test "should not include apostrophes in slug" do
    world_location = create(:world_location, name: "Bob's bike")
    assert_equal "bobs-bike", world_location.slug
  end

  test "should set an analytics identifier on create" do
    world_location = create(:world_location, name: "Costa Rica")
    assert_equal "WL#{world_location.id}", world_location.analytics_identifier
  end

  test "has the correct display type for a world location" do
    world_location = build(:world_location)
    assert_equal "World location", world_location.display_type
  end

  test "has the correct display type for an international delegation" do
    world_location = build(:international_delegation)
    assert_equal "International delegation", world_location.display_type
  end

  test ".worldwide_organisations_with_sponsoring_organisations returns all related organisations" do
    world_location = create(:world_location, :with_worldwide_organisations)
    related_organisations = world_location.worldwide_organisations +
      world_location.worldwide_organisations
        .map { |orgs| orgs.sponsoring_organisations.to_a }.flatten

    assert_equal related_organisations, world_location.worldwide_organisations_with_sponsoring_organisations
  end

  test "ordered_by_name sorts by the I18n.default_locale translation for name" do
    world_location1 = create(:world_location, name: "Neverland")
    world_location2 = create(:world_location, name: "Middle Earth")
    world_location3 = create(:world_location, name: "Narnia")

    I18n.with_locale(I18n.default_locale) do
      assert_equal [world_location2, world_location3, world_location1], WorldLocation.ordered_by_name
    end
  end

  test "ordered_by_name uses the I18n.default_locale ordering even if the current locale is not I18n.default_locale" do
    world_location1 = create(:world_location, name: "Neverland")
    world_location2 = create(:world_location, name: "Middle Earth")
    world_location3 = create(:world_location, name: "Narnia")

    I18n.with_locale(:fr) do
      world_location1.name = "Pays imaginaire"
      world_location1.save!
      world_location2.name = "Terre du Milieu"
      world_location2.save!

      assert_equal [world_location2, world_location3, world_location1], WorldLocation.ordered_by_name
    end
  end

  test "all_by_type should group world locations by type sorting the types by their sort order and locations by their name" do
    location1 = create(:world_location, world_location_type: "world_location", name: "Narnia")
    location2 = create(:world_location, world_location_type: "international_delegation", name: "Neverland")
    location3 = create(:world_location, world_location_type: "world_location", name: "Middle Earth")

    assert_equal({ "world_location" => [location3, location1], "international_delegation" => [location2] }, WorldLocation.all_by_type)
  end

  test "we can find those that are countries" do
    world_location = create(:world_location)
    international_delegation = create(:international_delegation)

    countries = WorldLocation.countries
    assert countries.include?(world_location)
    assert_not countries.include?(international_delegation)
  end

  test "we can find those that represent something geographic (if not neccessarily a world location)" do
    world_location = create(:world_location)
    international_delegation = create(:international_delegation)

    geographic = WorldLocation.geographical
    assert geographic.include?(world_location)
    assert_not geographic.include?(international_delegation)
  end

  test "public_path returns the correct path" do
    object = create(:world_location, slug: "foo")
    assert_equal "/world/foo", object.public_path
  end

  test "public_path returns the correct path with options" do
    object = create(:world_location, slug: "foo")
    assert_equal "/world/foo?cachebust=123", object.public_path(cachebust: "123")
  end

  test "public_url returns the url and appends options" do
    object = create(:world_location, slug: "foo")
    assert_equal "https://www.test.gov.uk/world/foo?cachebust=123", object.public_url(cachebust: "123")
  end

  test "should send the world index page to publishing api when a world location is created" do
    PublishWorldIndexPage.any_instance.expects(:publish)

    create(:world_location)
  end

  test "should send the world index page to publishing api when a world location is updated" do
    field = create(:world_location, name: "Field Name")

    PublishWorldIndexPage.any_instance.expects(:publish)

    field.update!(name: "New Field Name")
  end

  test "should send the world index page to publishing api when a world location is destroyed" do
    field = create(:world_location, name: "Field Name")

    PublishWorldIndexPage.any_instance.expects(:publish)

    field.destroy!
  end
end
