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

  test "setting access_limited = true bridges to access_limiting = 'organisations'" do
    edition = build(:limited_access_edition)
    edition.access_limited = true
    assert_equal "organisations", edition.access_limiting
  end

  test "setting access_limited = false bridges to access_limiting = 'none'" do
    edition = build(:limited_access_edition)
    edition.access_limited = false
    assert_equal "none", edition.access_limiting
  end

  test "setting access_limiting = 'organisations' bridges to access_limited = true" do
    edition = build(:limited_access_edition)
    edition.access_limiting = "organisations"
    assert edition.access_limited?
  end

  test "setting access_limiting = 'individuals' bridges to access_limited = true" do
    edition = build(:limited_access_edition)
    edition.access_limiting = "individuals"
    assert edition.access_limited?
  end

  test "setting access_limiting = 'none' bridges to access_limited = false" do
    edition = build(:limited_access_edition)
    edition.access_limiting = "organisations"
    edition.access_limiting = "none"
    assert_not edition.access_limited?
  end

  test "bridge writers persist both columns" do
    edition = build(:limited_access_edition)
    edition.access_limited = true
    edition.save!
    edition.reload
    assert edition.access_limited?
    assert_equal "organisations", edition.access_limiting

    edition.access_limiting = "individuals"
    edition.save!
    edition.reload
    assert edition.access_limited?
    assert_equal "individuals", edition.access_limiting
  end

  test "new instance of default-limited edition has access_limiting = 'organisations'" do
    assert_equal "organisations", build(:limited_by_default_edition).access_limiting
  end
end
