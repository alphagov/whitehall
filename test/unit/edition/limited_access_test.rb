require "test_helper"

class Edition::LimitedAccessTest < ActiveSupport::TestCase
  class LimitedAccessEdition < Edition
    include Edition::LimitedAccess
    include Edition::Organisations
  end

  class LimitedByDefaultEdition < LimitedAccessEdition
    def self.access_limited_by_default?
      true
    end
  end

  FactoryBot.define do
    factory :limited_access_edition, class: LimitedAccessEdition, parent: :edition_with_organisations do
    end
    factory :limited_by_default_edition, class: LimitedByDefaultEdition, parent: :limited_access_edition do
    end
  end

  test "sets access_limit on new instances according to class.access_limited_by_default?" do
    assert_not build(:limited_access_edition).access_limited?
    assert build(:limited_by_default_edition).access_limited?
  end

  test "can persist limited access flag (regardless of <class>.access_limited_by_default?)" do
    e = build(:limited_by_default_edition)
    e.access_limited = true
    e.save!
    assert e.reload.access_limited?
    e.access_limited = false
    e.save!
    assert_not e.reload.access_limited?
  end

  test "can select all editions accessible to a particular user" do
    my_organisation = create(:organisation)
    other_organisation = create(:organisation)
    user = create(:user, organisation: my_organisation)
    accessible = [
      create(:draft_news_article),
      create(:draft_publication, publication_type: PublicationType::NationalStatistics, access_limited: true, organisations: [my_organisation]),
      create(:draft_publication, publication_type: PublicationType::NationalStatistics, access_limited: true, organisations: [other_organisation], authors: [user]),
      create(:draft_publication, publication_type: PublicationType::NationalStatistics, access_limited: false, organisations: [other_organisation])
    ]
    inaccessible = create(:draft_publication, publication_type: PublicationType::NationalStatistics, access_limited: true, organisations: [other_organisation])

    accessible.each.with_index do |edition, i|
      assert Edition.accessible_to(user).include?(edition), "doc #{i} should be accessible"
    end
    assert_not Edition.accessible_to(user).include?(inaccessible)
  end

  test "can select all editions accessible to a particular world user, respecting access_limit, org and location" do
    my_organisation = create(:organisation)
    other_organisation = create(:organisation)
    my_location = create(:world_location)
    other_location = create(:world_location)
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
      assert_not Edition.accessible_to(user).include?(edition), "doc #{i} should not be accessible"
    end
  end

  test '#access_limited_object returns self' do
    edition = LimitedAccessEdition.new

    assert_equal edition, edition.access_limited_object
  end

  test 'is not accessible if no user specified' do
    edition = LimitedAccessEdition.new

    assert_not edition.accessible_to?(nil)
  end

  test 'is not accessible if edition is not accessible to user' do
    user = build(:user)
    edition_id = 123
    edition = LimitedAccessEdition.new(id: edition_id)
    accessible_scope = stub('accessible-scope')
    LimitedAccessEdition.stubs(:accessible_to).with(user)
      .returns(accessible_scope)

    accessible_scope.stubs(:where).with(id: edition_id).returns([])

    assert_not edition.accessible_to?(user)
  end

  test 'is accessible if edition is accessible to user' do
    user = build(:user)
    edition_id = 123
    edition = LimitedAccessEdition.new(id: edition_id)
    accessible_scope = stub('accessible-scope')
    LimitedAccessEdition.stubs(:accessible_to).with(user)
      .returns(accessible_scope)

    accessible_scope.stubs(:where).with(id: edition_id).returns([edition_id])

    assert edition.accessible_to?(user)
  end
end
