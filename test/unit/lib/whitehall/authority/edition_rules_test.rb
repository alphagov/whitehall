require_relative "authority_test_helper"
require "ostruct"

class EditionRulesTest < ActiveSupport::TestCase
  include AuthorityTestHelper

  def user_in(organisation)
    OpenStruct.new(
      id: 1,
      gds_editor?: false,
      organisation:,
    )
  end

  def user_with_email(email)
    OpenStruct.new(
      id: 1,
      gds_editor?: false,
      email:,
    )
  end

  test "grants access when user's organisation is in access_limiting_organisations and flag is on" do
    feature_flags.switch! :access_limiting_organisations_ui, true

    org = build(:organisation)
    user = user_in(org)

    edition = build(:edition, access_limiting: "organisations")
    edition.stubs(:access_limiting_organisations).returns([org])

    assert enforcer_for(user, edition).can?(:see)
  end

  test "revokes access when the user's organisation is not in access_limiting_organisations and flag is on" do
    feature_flags.switch! :access_limiting_organisations_ui, true

    org1 = build(:organisation)
    org2 = build(:organisation)
    user = user_in(org1)

    edition = build(:edition, access_limiting: "organisations")
    edition.stubs(:access_limiting_organisations).returns([org2])

    assert_not enforcer_for(user, edition).can?(:see)
  end

  test "grants access when user's email is in access_limiting_individuals and flag is on" do
    feature_flags.switch! :access_limiting_individuals_ui, true

    user = user_with_email("user@example.com")

    edition = build(:edition, access_limiting: "individuals")
    edition.stubs(:access_limiting_individuals).returns([OpenStruct.new(email: "user@example.com")])

    assert enforcer_for(user, edition).can?(:see)
  end

  test "grants access when user's email matches an access_limiting_individual case-insensitively and flag is on" do
    feature_flags.switch! :access_limiting_individuals_ui, true

    user = user_with_email("user@example.com")

    edition = build(:edition, access_limiting: "individuals")
    edition.stubs(:access_limiting_individuals).returns([OpenStruct.new(email: "User@Example.com")])

    assert enforcer_for(user, edition).can?(:see)
  end

  test "revokes access when user's email is not in access_limiting_individuals and flag is on" do
    feature_flags.switch! :access_limiting_individuals_ui, true

    user = user_with_email("user@example.com")

    edition = build(:edition, access_limiting: "individuals")
    edition.stubs(:access_limiting_individuals).returns([OpenStruct.new(email: "someone-else@example.com")])

    assert_not enforcer_for(user, edition).can?(:see)
  end

  test "grants access based on lead/supporting organisations when flag is off" do
    org1 = build(:organisation)
    org2 = build(:organisation)
    user = user_in(org1)

    edition = build(:consultation, access_limiting: "organisations")
    edition.stubs(:organisations).returns([org1])
    edition.stubs(:access_limiting_organisations).returns([org2])

    assert enforcer_for(user, edition).can?(:see)
  end

  test "revokes access based on lead/supporting organisations when flag is off" do
    org1 = build(:organisation)
    org2 = build(:organisation)
    user = user_in(org1)

    edition = build(:consultation, access_limiting: "organisations")
    edition.stubs(:organisations).returns([org2])

    assert_not enforcer_for(user, edition).can?(:see)
  end

  test "grants access when access limiting is 'none'" do
    edition = build(:edition, access_limiting: "none")
    user = create(:user)

    assert enforcer_for(user, edition).can?(:see)
  end

  test "revokes access when the user does not have an organisation, and flag is on" do
    feature_flags.switch! :access_limiting_organisations_ui, true

    org = build(:organisation)
    user = create(:user, organisation: nil)

    edition = build(:edition, access_limiting: "organisations")
    edition.stubs(:access_limiting_organisations).returns([org])

    assert_not enforcer_for(user, edition).can?(:see)
  end

  test "revokes access when the user does not have an organisation, and flag is off" do
    org = create(:organisation)
    user = create(:user, organisation: nil)

    edition = build(:consultation, access_limiting: "organisations")
    edition.stubs(:organisations).returns([org])

    assert_not enforcer_for(user, edition).can?(:see)
  end

  test "revokes access when access_limiting it set to 'organisations', but there are no access_limiting_organisations on the edition, and flag is on" do
    #  Special case to cover migration issues. In the latest validation this scenario is not really feasible.
    feature_flags.switch! :access_limiting_organisations_ui, true

    org1 = build(:organisation)
    user = user_in(org1)

    edition = build(:edition, access_limiting: "organisations")
    edition.stubs(:access_limiting_organisations).returns([])

    assert_not enforcer_for(user, edition).can?(:see)
  end

  test "revokes access when access_limiting it set to 'individuals', but there are no access_limiting_individuals on the edition, and flag is on" do
    #  Special case to cover migration issues. In the latest validation this scenario is not really feasible.
    feature_flags.switch! :access_limiting_individuals_ui, true

    org1 = build(:organisation)
    user = user_in(org1)

    edition = build(:edition, access_limiting: "individuals")
    edition.stubs(:access_limiting_individuals).returns([])

    assert_not enforcer_for(user, edition).can?(:see)
  end
end
