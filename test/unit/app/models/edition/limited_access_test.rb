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
    e.access_limiting = "organisations"
    e.save!
    assert e.reload.access_limited?
    e.access_limiting = "none"
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
    edition = LimitedAccessEdition.new(id: edition_id, access_limiting: "organisations")

    assert_not edition.accessible_to?(user)
  end

  test "is accessible if edition is accessible to user" do
    user = build(:user)
    edition_id = 123
    edition = LimitedAccessEdition.new(id: edition_id)

    assert edition.accessible_to?(user)
  end

  test "is invalid when access_limiting is set to 'organisations' and no access limiting organisations are selected" do
    @feature_flags.switch!(:access_limiting_organisations_ui, true)

    edition = create(:edition)
    edition.access_limiting = :organisations
    edition.access_limiting_organisation_ids = []

    assert_not edition.valid?
    assert_includes edition.errors[:access_limiting_organisation_ids],
                    "must include at least one organisation when access limiting is enabled"
  end

  test "is valid when access_limiting is set to 'organisations' and access limiting organisations are present" do
    @feature_flags.switch!(:access_limiting_organisations_ui, true)
    org = create(:organisation)

    edition = create(:edition)
    edition.access_limiting = :organisations
    edition.access_limiting_organisation_ids = [org.id]

    assert edition.valid?
  end

  test "is valid when access_limiting is set to 'none' regardless of access limiting organisations" do
    @feature_flags.switch!(:access_limiting_organisations_ui, true)

    edition = create(:limited_access_edition, access_limiting: :none)
    edition.access_limiting_organisation_ids = []
    assert edition.valid?
  end

  test "is valid when access_limiting is set to 'organisations' and no access limiting organisations are selected when flag is off" do
    edition = create(:consultation, access_limiting: :organisations)
    edition.access_limiting_organisation_ids = []
    assert edition.valid?
  end

  test "setting access_limiting writes through to the legacy access_limited column" do
    edition = build(:limited_access_edition)

    edition.access_limiting = "organisations"
    assert_equal true, edition[:access_limited]

    edition.access_limiting = "individuals"
    assert_equal true, edition[:access_limited]

    edition.access_limiting = "none"
    assert_equal false, edition[:access_limited]
  end

  test "access_limiting persists across save/reload and keeps both columns in sync" do
    edition = build(:limited_access_edition)
    edition.access_limiting = "organisations"
    edition.save!
    edition.reload
    assert edition.access_limited?
    assert_equal "organisations", edition.access_limiting
    assert_equal true, edition[:access_limited]

    edition.access_limiting = "individuals"
    edition.save!
    edition.reload
    assert edition.access_limited?
    assert_equal "individuals", edition.access_limiting
    assert_equal true, edition[:access_limited]
  end

  test "new instance of default-limited edition has access_limiting = 'organisations'" do
    assert_equal "organisations", build(:limited_by_default_edition).access_limiting
  end

  test "access_limited? reads from access_limiting, not the legacy boolean" do
    edition = create(:limited_access_edition, access_limiting: "organisations")
    # Force the legacy and new columns out of sync via raw SQL (bypasses bridge)
    Edition.where(id: edition.id).update_all(access_limited: true, access_limiting: "none")
    edition.reload
    assert_not edition.access_limited?, "access_limited? should reflect the new column"

    Edition.where(id: edition.id).update_all(access_limited: false, access_limiting: "organisations")
    edition.reload
    assert edition.access_limited?, "access_limited? should reflect the new column"
  end

  test "access_limited? is true for organisations and individuals modes" do
    edition = build(:limited_access_edition)
    edition.access_limiting = "organisations"
    assert edition.access_limited?
    edition.access_limiting = "individuals"
    assert edition.access_limited?
  end

  test "access_limited? is false when access_limiting is none or nil" do
    edition = build(:limited_access_edition)
    edition.access_limiting = "none"
    assert_not edition.access_limited?

    edition.access_limiting = nil
    assert_not edition.access_limited?
  end

  test "access_limiting is reset to none and access_limiting_organisations are not carried over when redrafting" do
    organisation = create(:organisation)
    edition = create(
      :consultation,
      :submitted,
      access_limiting: :organisations,
      create_default_organisation: false,
      lead_organisations: [organisation],
    )
    edition.edition_access_limiting_organisations.create!(organisation: organisation)
    EditionPublisher.new(edition).perform!

    new_draft = edition.create_draft(create(:writer))

    assert new_draft.access_limiting_none?
    assert_empty new_draft.access_limiting_organisations
  end
end
