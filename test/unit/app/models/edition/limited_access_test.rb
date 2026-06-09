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

  test "#access_limited_object returns self" do
    edition = LimitedAccessEdition.new

    assert_equal edition, edition.access_limited_object
  end

  test "is not accessible if no user specified" do
    edition = LimitedAccessEdition.new

    assert_not edition.accessible_to?(nil)
  end

  test "is not accessible if edition is not accessible to user" do
    user = build(:user)
    edition_id = 123
    edition = LimitedAccessEdition.new(id: edition_id, access_limited: true)

    assert_not edition.accessible_to?(user)
  end

  test "is accessible if edition is accessible to user" do
    user = build(:user)
    edition_id = 123
    edition = LimitedAccessEdition.new(id: edition_id)

    assert edition.accessible_to?(user)
  end

  test "is invalid when access_limited is true and no access limiting organisations are selected" do
    @feature_flags.switch!(:access_limiting_organisations_ui, true)

    edition = create(:limited_access_edition, access_limited: true)
    edition.access_limiting_organisation_ids = []

    assert_not edition.valid?
    assert_includes edition.errors[:access_limiting_organisation_ids],
                    "must include at least one organisation when access limiting is enabled"
  end

  test "is valid when access_limited is true and access limiting organisations are present" do
    @feature_flags.switch!(:access_limiting_organisations_ui, true)
    org = create(:organisation)

    edition = create(:limited_access_edition, access_limited: true)
    edition.access_limiting_organisation_ids = [org.id]

    assert edition.valid?
  end

  test "is valid when access_limited is false regardless of access limiting organisations" do
    @feature_flags.switch!(:access_limiting_organisations_ui, true)

    edition = create(:limited_access_edition, access_limited: false)
    edition.access_limiting_organisation_ids = []
    assert edition.valid?
  end

  test "is valid when access_limited is true and no access limiting organisations are selected when flag is off" do
    edition = create(:consultation, access_limited: true)
    edition.access_limiting_organisation_ids = []

    assert edition.valid?
  end
end
