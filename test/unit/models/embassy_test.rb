require "test_helper"

class EmbassyTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:world_location) { build(:world_location) }
  let(:embassy) { Embassy.new(world_location) }

  it "delegates to the world location" do
    world_location.name = "Narnia"
    assert_equal "Narnia", embassy.name
  end

  context "when there are no organisations" do
    it "returns false for #can_assist_british_nationals?" do
      assert_not embassy.can_assist_british_nationals?
    end

    it "returns false for #can_assist_in_location?" do
      assert_not embassy.can_assist_in_location?
    end

    it "returns nil for #remote_office" do
      assert_nil embassy.remote_office
    end

    it "returns no #organisations_with_embassy_offices" do
      assert embassy.organisations_with_embassy_offices.empty?
    end
  end

  context "when there are organisations with embassy offices in the world location" do
    before do
      organisation = create(:worldwide_organisation, world_locations: [world_location])
      contact = create(:contact_with_country, country: world_location)
      create(:worldwide_office,
             contact:,
             worldwide_organisation: organisation,
             worldwide_office_type: WorldwideOfficeType::EMBASSY_OFFICE_TYPES.first)
    end

    it "returns true for #can_assist_british_nationals?" do
      assert embassy.can_assist_british_nationals?
    end

    it "returns true for #can_assist_in_location?" do
      assert embassy.can_assist_in_location?
    end

    it "returns nil for #remote_office" do
      assert_nil embassy.remote_office
    end

    it "returns a single #organisations_with_embassy_offices" do
      assert_equal 1, embassy.organisations_with_embassy_offices.count
    end
  end

  context "when there are organisations with embassy offices in unspecified countries" do
    before do
      organisation = create(:worldwide_organisation, world_locations: [world_location])
      contact = create(:contact, country: nil)
      create(:worldwide_office,
             contact:,
             worldwide_organisation: organisation,
             worldwide_office_type: WorldwideOfficeType::EMBASSY_OFFICE_TYPES.first)
    end

    it "returns true for #can_assist_british_nationals?" do
      assert embassy.can_assist_british_nationals?
    end

    it "returns true for #can_assist_in_location?" do
      assert embassy.can_assist_in_location?
    end

    it "returns nil for #remote_office" do
      assert_nil embassy.remote_office
    end

    it "returns a single #organisations_with_embassy_offices" do
      assert_equal 1, embassy.organisations_with_embassy_offices.count
    end
  end

  context "when the world location is a special case" do
    let(:world_location) { build(:world_location, name: Embassy::SPECIAL_CASES.keys.first) }

    it "returns true for #can_assist_british_nationals?" do
      assert embassy.can_assist_british_nationals?
    end

    it "returns false for #can_assist_in_location?" do
      assert_not embassy.can_assist_in_location?
    end

    it "returns no #organisations_with_embassy_offices" do
      assert embassy.organisations_with_embassy_offices.empty?
    end

    it "returns a #remote_office" do
      expected = Embassy::RemoteOffice.new(
        name: "Foreign, Commonwealth and Development Office",
        location: "the UK",
        path: "/government/organisations/foreign-commonwealth-development-office",
      )
      assert_equal expected, embassy.remote_office
    end
  end

  context "when there are organisations with embassy offices in other world locations" do
    let(:other_location) { create(:world_location) }

    before do
      organisation = create(:worldwide_organisation,
                            world_locations: [world_location],
                            name: "org-name",
                            slug: "org-slug")
      contact = create(:contact_with_country, country: other_location)
      create(:worldwide_office,
             contact:,
             worldwide_organisation: organisation,
             worldwide_office_type: WorldwideOfficeType::EMBASSY_OFFICE_TYPES.first)
    end

    it "returns true for #can_assist_british_nationals?" do
      assert embassy.can_assist_british_nationals?
    end

    it "returns false for #can_assist_in_location?" do
      assert_not embassy.can_assist_in_location?
    end

    it "returns a single #organisations_with_embassy_offices" do
      assert_equal 1, embassy.organisations_with_embassy_offices.count
    end

    it "returns #remote_office" do
      expected = Embassy::RemoteOffice.new(
        name: "org-name",
        location: other_location,
        path: "/world/organisations/org-slug",
      )
      assert_equal expected, embassy.remote_office
    end
  end

  context "when there is an organisation with two embassy offices, one in an unknown location and one in another world location" do
    let(:other_location) { create(:world_location) }

    before do
      organisation = create(:worldwide_organisation,
                            world_locations: [world_location],
                            name: "org-name",
                            slug: "org-slug")
      remote_office_contact = create(:contact_with_country, country: other_location)
      unknown_location_contact = create(:contact, country: nil)
      create(:worldwide_office,
             contact: remote_office_contact,
             worldwide_organisation: organisation,
             worldwide_office_type: WorldwideOfficeType::EMBASSY_OFFICE_TYPES.first)
      create(:worldwide_office,
             contact: unknown_location_contact,
             worldwide_organisation: organisation,
             worldwide_office_type: WorldwideOfficeType::EMBASSY_OFFICE_TYPES.first)
    end

    it "returns the remote office from #remote_office" do
      expected = Embassy::RemoteOffice.new(
        name: "org-name",
        location: other_location,
        path: "/world/organisations/org-slug",
      )
      assert_equal expected, embassy.remote_office
    end
  end

  context "when there is an organisation with two offices in two remote countries and one isn't an embassy" do
    let(:second_location) { create(:world_location) }
    let(:third_location) { create(:world_location) }

    before do
      organisation = create(:worldwide_organisation,
                            world_locations: [world_location],
                            name: "org-name",
                            slug: "org-slug")
      second_location_contact = create(:contact_with_country, country: second_location)
      third_location_contact = create(:contact_with_country, country: third_location)
      create(:worldwide_office,
             contact: second_location_contact,
             worldwide_organisation: organisation,
             worldwide_office_type: WorldwideOfficeType::Other)
      create(:worldwide_office,
             contact: third_location_contact,
             worldwide_organisation: organisation,
             worldwide_office_type: WorldwideOfficeType::EMBASSY_OFFICE_TYPES.first)
    end

    it "returns the embassy office from #remote_office" do
      expected = Embassy::RemoteOffice.new(
        name: "org-name",
        location: third_location,
        path: "/world/organisations/org-slug",
      )
      assert_equal expected, embassy.remote_office
    end
  end
end
