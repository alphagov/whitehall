require "test_helper"

class Edition::LimitedAccessTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  class LimitedAccessEdition < Edition
    include Edition::LimitedAccess
    include Edition::Organisations
  end

  FactoryBot.define do
    factory :limited_access_edition, class: LimitedAccessEdition, parent: :edition_with_organisations do
    end
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

  context "with access_limiting_organisations_ui flag on" do
    test "is valid when access_limiting is set to 'organisations' and access limiting organisations are present" do
      @feature_flags.switch!(:access_limiting_organisations_ui, true)
      org = create(:organisation)

      edition = build(:edition)
      edition.access_limiting = :organisations
      edition.access_limiting_organisation_ids = [org.id]

      assert edition.valid?
    end

    test "is valid when access_limiting is set to 'none' regardless of access limiting organisations" do
      @feature_flags.switch!(:access_limiting_organisations_ui, true)

      edition = build(:limited_access_edition, access_limiting: :none)
      edition.access_limiting_organisation_ids = []
      assert edition.valid?
    end

    test "is invalid when access_limiting is set to 'organisations' and no access limiting organisations are present" do
      @feature_flags.switch!(:access_limiting_organisations_ui, true)

      edition = build(:limited_access_edition, access_limiting: :organisations)
      edition.access_limiting_organisation_ids = []

      assert_not edition.valid?
      assert_includes edition.errors[:access_limiting_organisation_ids], "must include at least one organisation"
    end

    test "is invalid when user does not have an organisation" do
      @feature_flags.switch!(:access_limiting_organisations_ui, true)
      user = build(:user, organisation: nil)
      edition = build(:limited_access_edition, access_limiting: "organisations", access_limiting_organisation_ids: [create(:organisation).id])
      edition.current_user_for_validation = user

      assert_invalid edition
      assert_includes edition.errors[:access_limiting_organisation_ids], "must include your own organisation"
    end

    test "is invalid when the user's organisation is not included in the access limiting organisations" do
      @feature_flags.switch!(:access_limiting_organisations_ui, true)
      user_org = create(:organisation)
      access_limiting_org = create(:organisation)
      user = build(:user, organisation: user_org)

      edition = build(:limited_access_edition, access_limiting: "organisations")
      edition.access_limiting_organisation_ids = [access_limiting_org.id]
      edition.current_user_for_validation = user

      assert_not edition.valid?
      assert_includes edition.errors[:access_limiting_organisation_ids], "must include your own organisation"
    end

    test "create does not persist edition with invalid access_limiting_organisations" do
      @feature_flags.switch!(:access_limiting_organisations_ui, true)
      edition = build(:limited_access_edition, access_limiting: "organisations")
      edition.access_limiting_organisation_ids = []

      assert_no_changes -> { AccessLimitingOrganisation.count } do
        assert_not edition.save
      end
      assert_equal [], edition.access_limiting_organisation_ids
    end

    test "create does not persist edition with valid access_limiting_organisations when another field is invalid" do
      @feature_flags.switch!(:access_limiting_organisations_ui, true)
      org = create(:organisation)
      edition = build(:limited_access_edition, access_limiting: "organisations", access_limiting_organisation_ids: [org.id])
      edition.title = ""

      assert_no_changes -> { AccessLimitingOrganisation.count } do
        assert_not edition.save
      end
      assert_equal [org.id], edition.access_limiting_organisation_ids
    end

    test "creates and updates edition with access limiting organisations" do
      @feature_flags.switch!(:access_limiting_organisations_ui, true)
      original_org = create(:organisation)
      edition = create(:limited_access_edition, access_limiting: "organisations", access_limiting_organisation_ids: [original_org.id])

      assert_equal [original_org.id], edition.reload.edition_access_limiting_organisations.map(&:organisation_id)

      new_org = create(:organisation)
      edition.access_limiting_organisation_ids = [new_org.id]
      edition.save!

      assert_equal [new_org.id], edition.reload.edition_access_limiting_organisations.map(&:organisation_id)
    end

    test "update: does not persist valid access_limiting_organisations on assignment" do
      @feature_flags.switch!(:access_limiting_organisations_ui, true)
      original_org = create(:organisation)
      edition = create(:limited_access_edition, access_limiting: "organisations", access_limiting_organisation_ids: [original_org.id])

      updated_org = create(:organisation)
      edition.access_limiting_organisation_ids = [updated_org.id]

      assert_equal [original_org.id], edition.reload.edition_access_limiting_organisations.map(&:organisation_id)
    end

    test "update does not persist invalid assigned access_limiting_organisations" do
      @feature_flags.switch!(:access_limiting_organisations_ui, true)

      old_org = create(:organisation)
      edition = create(:limited_access_edition, access_limiting: "organisations", access_limiting_organisation_ids: [old_org.id])
      edition.access_limiting_organisation_ids = []

      assert_not edition.save
      assert_includes edition.errors[:access_limiting_organisation_ids], "must include at least one organisation"
      assert_equal [], edition.access_limiting_organisation_ids # In-memory should show the cleared value the user set
      assert_equal [old_org.id], edition.reload.edition_access_limiting_organisations.map(&:organisation_id) # DB should remain unchanged (still the original org)
    end

    test "update does not persist valid assigned access_limiting_organisations when another field is invalid" do
      @feature_flags.switch!(:access_limiting_organisations_ui, true)

      old_org = create(:organisation)
      edition = create(:limited_access_edition, access_limiting: "organisations", access_limiting_organisation_ids: [old_org.id])
      new_org = create(:organisation)
      edition.access_limiting_organisation_ids = [new_org.id]
      edition.title = ""

      assert_not edition.save
      assert_equal [new_org.id], edition.access_limiting_organisation_ids # In-memory should reflect the newly assigned orgs
      assert_equal [old_org.id], edition.reload.edition_access_limiting_organisations.map(&:organisation_id) # DB should remain unchanged (still the original org)
    end
  end

  context "with access_limiting_organisations_ui flag off" do
    setup do
      @feature_flags.switch!(:access_limiting_organisations_ui, false)
    end

    test "is valid when access_limiting is set to 'organisations' and no access limiting organisations are selected" do
      edition = create(:consultation, access_limiting: :organisations)
      edition.access_limiting_organisation_ids = []
      assert edition.valid?
    end

    test "is invalid when access_limiting is set to 'organisations' and no edition organisations are selected" do
      edition = create(:consultation, access_limiting: :organisations)
      edition.organisation_ids = []

      assert_not edition.valid?
      assert_includes edition.errors[:lead_organisation_ids], "at least one required"
    end

    test "is invalid when user does not have an organisation" do
      user = build(:user, organisation: nil)
      edition = build(:limited_access_edition, access_limiting: "organisations")
      edition.lead_organisation_ids = [create(:organisation).id]
      edition.current_user_for_validation = user

      assert_invalid edition
      assert_includes edition.errors[:base], "Lead or supporting organisations must include your own organisation"
    end

    test "is invalid when the user's organisation is not included in the edition organisations" do
      user_org = create(:organisation)
      user = build(:user, organisation: user_org)
      edition = build(:limited_access_edition, access_limiting: "organisations", lead_organisation_ids: [create(:organisation).id])
      edition.current_user_for_validation = user

      assert_not edition.valid?
      assert_includes edition.errors[:base], "Lead or supporting organisations must include your own organisation"
    end
  end

  test "saves access_limiting_individuals with lowercased emails when access_limiting is set to 'individuals'" do
    edition = build(:limited_access_edition)
    edition.access_limiting = "individuals"
    edition.access_limiting_individual_emails = "TEST@test.com, Example@example.com"
    edition.save!

    assert edition.reload.access_limiting_individuals.exists?(email: "test@test.com")
    assert edition.reload.access_limiting_individuals.exists?(email: "example@example.com")
  end

  test "saves and reads access_limiting_individuals when the email separators are comma, semicolon, or newline" do
    edition = build(:edition)
    edition.access_limiting = "individuals"
    edition.access_limiting_individual_emails =
      "test@test.com,     example@example.com;\n  some_other_test@test.com\n another_example@example.com"

    edition.save!

    expected_emails = %w[test@test.com example@example.com some_other_test@test.com another_example@example.com]
    actual_emails = edition.access_limiting_individuals.pluck(:email)
    assert_equal actual_emails.sort, expected_emails.sort
    assert_equal "test@test.com, example@example.com, some_other_test@test.com, another_example@example.com", edition.access_limiting_individual_emails
  end

  test "is invalid when the email separator is space" do
    @feature_flags.switch!(:access_limiting_individuals_ui, true)

    edition = build(:limited_access_edition)
    edition.access_limiting = "individuals"
    edition.access_limiting_individual_emails = "test@test.com example@example.com some_test@test.com"

    assert_not edition.valid?
    assert_includes edition.errors[:access_limiting_individual_emails], "must contain valid email addresses"
  end

  test "does not persist access_limiting_individuals on assignment" do
    edition = build(:limited_access_edition)
    edition.access_limiting = "individuals"
    edition.access_limiting_individual_emails = "test@test.com"
    edition.save!

    edition.access_limiting_individual_emails = "example@example.com"

    assert edition.reload.access_limiting_individuals.exists?(email: "test@test.com")
    assert_not edition.reload.access_limiting_individuals.exists?(email: "example@example.com")
  end

  test "is invalid when access_limiting is set to 'individuals' and no access limiting emails are selected" do
    @feature_flags.switch!(:access_limiting_individuals_ui, true)

    edition = create(:limited_access_edition)
    edition.access_limiting = :individuals
    edition.access_limiting_individual_emails = ""

    assert_not edition.valid?
    assert_includes edition.errors[:access_limiting_individual_emails],
                    "must include at least one email when individual access limiting is enabled"
  end

  test "is valid when access_limiting is set to 'individuals' and access limiting emails are present" do
    @feature_flags.switch!(:access_limiting_individuals_ui, true)

    edition = create(:limited_access_edition)
    edition.access_limiting = :individuals
    edition.access_limiting_individual_emails = "user@example.com"

    assert edition.valid?
  end

  test "is invalid when access_limiting is set to 'individuals' and the provided email is not an email address" do
    @feature_flags.switch!(:access_limiting_individuals_ui, true)

    edition = create(:limited_access_edition)
    edition.access_limiting = :individuals
    edition.access_limiting_individual_emails = "not-an-email"

    assert_not edition.valid?
    assert_includes edition.errors[:access_limiting_individual_emails],
                    "must contain valid email addresses"
    assert_empty edition.errors[:"access_limiting_individuals.email"]
  end

  test "is invalid when an access limiting individual email has no top-level domain" do
    @feature_flags.switch!(:access_limiting_individuals_ui, true)

    edition = create(:limited_access_edition)
    edition.access_limiting = :individuals
    edition.access_limiting_individual_emails = "test@test"

    assert_not edition.valid?
    assert_includes edition.errors[:access_limiting_individual_emails], "must contain valid email addresses"
  end

  test "is invalid when valid emails are mixed in with badly formatted emails" do
    @feature_flags.switch!(:access_limiting_individuals_ui, true)

    edition = create(:limited_access_edition)
    edition.access_limiting = :individuals
    edition.access_limiting_individual_emails = "user@example.com, gibberish"

    assert_not edition.valid?
    assert_includes edition.errors[:access_limiting_individual_emails], "must contain valid email addresses"
  end

  test "is valid when access_limiting is set to 'none' regardless of access limiting individuals" do
    @feature_flags.switch!(:access_limiting_individuals_ui, true)

    edition = create(:limited_access_edition, access_limiting: :none)
    edition.access_limiting_individual_emails = ""
    assert edition.valid?
  end

  test "is invalid when access_limiting is set to 'individuals' and the current user's email is not included" do
    @feature_flags.switch!(:access_limiting_individuals_ui, true)

    user = build(:user, email: "user@example.com")
    edition = create(:limited_access_edition)
    edition.current_user_for_validation = user
    edition.access_limiting = :individuals
    edition.access_limiting_individual_emails = "another_user@example.com"

    assert_not edition.valid?
    assert_includes edition.errors[:access_limiting_individual_emails], "must include your own email"
  end

  test "recognizes the users's email as valid when mixed in with other badly formatted emails" do
    @feature_flags.switch!(:access_limiting_individuals_ui, true)

    user = build(:user, email: "user@example.com")
    edition = create(:limited_access_edition)
    edition.current_user_for_validation = user
    edition.access_limiting = :individuals
    edition.access_limiting_individual_emails = "user@example.com, gibberish"

    assert_not edition.valid?
    assert_not_includes edition.errors[:access_limiting_individual_emails], "must include your own email"
  end

  test "does not recognize the users's email as valid when the email separator is space" do
    @feature_flags.switch!(:access_limiting_individuals_ui, true)

    user = build(:user, email: "user@example.com")
    edition = create(:limited_access_edition)
    edition.current_user_for_validation = user
    edition.access_limiting = :individuals
    edition.access_limiting_individual_emails = "test@test.com example@example.com"

    assert_not edition.valid?
    assert_includes edition.errors[:access_limiting_individual_emails], "must include your own email"
    assert_includes edition.errors[:access_limiting_individual_emails], "must contain valid email addresses"
  end

  test "is valid when access_limiting is set to 'individuals' and no access limiting individuals are selected when flag is off" do
    edition = create(:consultation, access_limiting: :individuals)
    edition.access_limiting_individual_emails = ""
    assert edition.valid?
  end

  test "access_limiting persists across save/reload" do
    edition = build(:limited_access_edition, :access_limited_by_organisations)
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
end
