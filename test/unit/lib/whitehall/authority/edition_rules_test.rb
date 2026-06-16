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
end
