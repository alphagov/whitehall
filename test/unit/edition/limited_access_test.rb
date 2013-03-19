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

  test "when access is not limited, edition is accessible by anyone" do
    org1, org2 = build(:organisation), build(:organisation)
    e = create(:limited_access_edition, organisations: [org1], access_limited: false)

    user1 = build(:user, organisation: org1)
    user2 = build(:user, organisation: org2)

    assert e.accessible_by?(user1)
    assert e.accessible_by?(user2)
    assert e.accessible_by?(nil)
  end

  test "when access is limited, edition is accessible only by a person in the one of the edition's departments, or an author" do
    org1, org2, org3 = build(:organisation), build(:organisation), build(:organisation)

    user_in_org1 = build(:user, organisation: org1)
    user_in_org2 = build(:user, organisation: org2)
    author = build(:user, organisation: org3)

    e = create(:limited_access_edition, organisations: [org1], access_limited: true, authors: [author])

    assert e.accessible_by?(author)
    assert e.accessible_by?(user_in_org1)
    refute e.accessible_by?(user_in_org2)
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

  test "if access is not limited, edition is only accessible to a world user if it\'s about their location" do
    loc_1, loc_2 = build(:country), build(:country)
    editor_in_loc_1 = build(:world_editor, world_locations: [loc_1])
    writer_in_loc_1 = build(:world_writer, world_locations: [loc_1])
    editor_in_loc_2 = build(:world_editor, world_locations: [loc_2])
    writer_in_loc_2 = build(:world_writer, world_locations: [loc_2])

    e = create(:limited_access_edition, world_locations: [loc_2], access_limited: false)

    refute e.accessible_by?(editor_in_loc_1)
    refute e.accessible_by?(writer_in_loc_1)

    assert e.accessible_by?(editor_in_loc_2)
    assert e.accessible_by?(writer_in_loc_2)
  end

  test "if access is limited, edition is only accessible to a world user if it\'s about their location AND their org" do
    loc_1, loc_2 = build(:country), build(:country)
    org_1, org_2 = build(:organisation), build(:organisation)

    editor_in_org_1_loc_1 = build(:world_editor, world_locations: [loc_1], organisation: org_1)
    writer_in_org_1_loc_1 = build(:world_writer, world_locations: [loc_1], organisation: org_1)
    editor_in_org_1_loc_2 = build(:world_editor, world_locations: [loc_2], organisation: org_1)
    writer_in_org_1_loc_2 = build(:world_writer, world_locations: [loc_2], organisation: org_1)
    editor_in_org_2_loc_2 = build(:world_editor, world_locations: [loc_2], organisation: org_2)
    writer_in_org_2_loc_2 = build(:world_writer, world_locations: [loc_2], organisation: org_2)

    e = create(:limited_access_edition, world_locations: [loc_2], organisations: [org_2], access_limited: true)

    refute e.accessible_by?(editor_in_org_1_loc_1)
    refute e.accessible_by?(writer_in_org_1_loc_1)
    refute e.accessible_by?(editor_in_org_1_loc_2)
    refute e.accessible_by?(writer_in_org_1_loc_2)

    assert e.accessible_by?(editor_in_org_2_loc_2)
    assert e.accessible_by?(writer_in_org_2_loc_2)
  end

  test "can select all editions accessible to a particular world user, respecting access_limit, org and location" do
    my_organisation, other_organisation = create(:organisation), create(:organisation)
    my_location, other_location = create(:country), create(:country)
    user = create(:world_writer, organisation: my_organisation, world_locations: [my_location])
    accessible = [
      create(:draft_publication, access_limited: false, world_locations: [my_location]),
      create(:draft_publication, access_limited: true, organisations: [my_organisation], world_locations: [my_location]),
      create(:draft_publication, access_limited: true, organisations: [other_organisation], authors: [user], world_locations: [my_location]),
    ]
    inaccessible = [
      create(:draft_publication, access_limited: false, world_locations: [other_location]),
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