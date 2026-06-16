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

  test "access is enforced against access_limiting_organisations when flag is on and organisations are set" do
    feature_flags.switch! :access_limiting_organisations_ui, true

    org1 = build(:organisation)
    org2 = build(:organisation)
    user = user_in(org1)

    edition = build(:edition, access_limiting: "organisations")
    edition.stubs(:access_limiting_organisations).returns([org2])

    assert_not enforcer_for(user, edition).can?(:see)
  end

  test "access is granted when user's organisation is in access_limiting_organisations and flag is on" do
    feature_flags.switch! :access_limiting_organisations_ui, true

    org = build(:organisation)
    user = user_in(org)

    edition = build(:edition, access_limiting: "organisations")
    edition.stubs(:access_limiting_organisations).returns([org])

    assert enforcer_for(user, edition).can?(:see)
  end

  test "ignores access_limiting_organisations and uses lead/supporting organisations when flag is off" do
    org1 = build(:organisation)
    org2 = build(:organisation)
    user = user_in(org1)

    edition = FactoryBot.build(:consultation, access_limiting: "organisations")
    edition.stubs(:organisations).returns([org1])
    edition.stubs(:access_limiting_organisations).returns([org2])

    assert enforcer_for(user, edition).can?(:see)
  end
end
