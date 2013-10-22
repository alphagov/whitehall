require "test_helper"

class Edition::LimitedAccessTest < ActiveSupport::TestCase

  class LimitedAccessEdition < Edition
    include Edition::LimitedAccess
  end

  class LimitedByDefaultEdition < Edition
    include Edition::LimitedAccess
    def self.access_limited_by_default?
      true
    end
  end

  FactoryGirl.define do
    factory :limited_access_edition, class: LimitedAccessEdition, parent: :edition do
    end
    factory :limited_by_default_edition, class: LimitedByDefaultEdition, parent: :edition do
    end
  end

  test "sets access_limit on new instances according to class.access_limited_by_default?" do
    refute build(:limited_access_edition).access_limited?
    assert build(:limited_by_default_edition).access_limited?
  end

  test "can persist limited access flag (regardless of <class>.access_limited_by_default?)" do
    e = build(:limited_by_default_edition)
    e.access_limited = true
    e.save!
    assert e.reload.access_limited?
    e.access_limited = false
    e.save!
    refute e.reload.access_limited?
  end

  test "can select all editions accessible to a particular user" do
    my_organisation, other_organisation = create(:organisation), create(:organisation)
    user = create(:user, organisation: my_organisation)
    accessible = [
      create(:draft_policy),
      create(:draft_publication, publication_type: PublicationType::NationalStatistics, access_limited: true, organisations: [my_organisation]),
      create(:draft_publication, publication_type: PublicationType::NationalStatistics, access_limited: true, organisations: [other_organisation], authors: [user]),
      create(:draft_publication, publication_type: PublicationType::NationalStatistics, access_limited: false, organisations: [other_organisation])
    ]
    inaccessible = create(:draft_publication, publication_type: PublicationType::NationalStatistics, access_limited: true, organisations: [other_organisation])

    accessible.each.with_index do |edition, i|
      assert Edition.accessible_to(user).include?(edition), "doc #{i} should be accessible"
    end
    refute Edition.accessible_to(user).include?(inaccessible)
  end

  test "can select all editions accessible to a particular world user, respecting access_limit, org and location" do
    my_organisation, other_organisation = create(:organisation), create(:organisation)
    my_location, other_location = create(:world_location), create(:world_location)
    user = create(:world_writer, organisation: my_organisation, world_locations: [my_location])
    accessible = [
      create(:draft_publication, access_limited: false, world_locations: [my_location]),
      create(:draft_publication, access_limited: true, organisations: [my_organisation], world_locations: [my_location]),
      create(:draft_publication, access_limited: true, organisations: [other_organisation], authors: [user], world_locations: [my_location]),
    ]
    inaccessible = [
      create(:draft_publication, access_limited: false, world_locations: [other_location]),
      create(:draft_publication, access_limited: false, organisations: [my_organisation]),
      create(:draft_publication, access_limited: true, organisations: [my_organisation], world_locations: [other_location]),
      create(:draft_publication, access_limited: true, organisations: [other_organisation], world_locations: [my_location])
    ]

    accessible.each.with_index do |edition, i|
      assert Edition.accessible_to(user).include?(edition), "doc #{i} should be accessible"
    end
    inaccessible.each.with_index do |edition, i|
      refute Edition.accessible_to(user).include?(edition), "doc #{i} should not be accessible"
    end
  end

end
