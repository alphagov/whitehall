require_relative "authority_test_helper"
require "ostruct"

class EditionRulesTest < ActiveSupport::TestCase
  include AuthorityTestHelper

  def user_in(organisation, extra_attrs = {})
    OpenStruct.new(
      {
        id: 1,
        gds_editor?: false,
        gds_admin?: false,
        can_unpublish_historic_content?: false,
        organisation:,
      }.merge(extra_attrs),
    )
  end

  def org
    @org ||= build(:organisation)
  end

  def other_org
    @other_org ||= build(:organisation)
  end

  def historic_access_limited_edition(limiting_orgs)
    edition = build(:publication)
    edition.stubs(:historic?).returns(true)
    edition.stubs(:access_limiting_organisations?).returns(true)
    edition.stubs(:access_limiting_organisations).returns(limiting_orgs)
    edition.stubs(:organisations).returns(limiting_orgs)
    edition
  end

  def historic_unrestricted_edition
    edition = build(:edition)
    edition.stubs(:historic?).returns(true)
    edition.stubs(:access_limiting_organisations?).returns(false)
    edition
  end

  test "grants access based on lead/supporting organisations when flag is off" do
    user = user_in(org)
    edition = build(:consultation, access_limiting: "organisations")
    edition.stubs(:historic?).returns(false)
    edition.stubs(:access_limiting_organisations?).returns(true)
    edition.stubs(:access_limiting_organisations).returns([other_org])
    edition.stubs(:organisations).returns([org])

    assert enforcer_for(user, edition).can?(:see)
  end

  test "revokes access based on lead/supporting organisations when flag is off" do
    user = user_in(org)
    edition = build(:consultation, access_limiting: "organisations")
    edition.stubs(:historic?).returns(false)
    edition.stubs(:access_limiting_organisations?).returns(true)
    edition.stubs(:access_limiting_organisations).returns([other_org])
    edition.stubs(:organisations).returns([other_org])

    assert_not enforcer_for(user, edition).can?(:see)
  end

  test "grants access when access limiting is 'none'" do
    user = user_in(org)
    edition = build(:edition, access_limiting: "none")
    edition.stubs(:historic?).returns(false)
    edition.stubs(:access_limiting_organisations?).returns(false)

    assert enforcer_for(user, edition).can?(:see)
  end

  test "revokes access when the user does not have an organisation, and flag is off" do
    user = user_in(nil)
    edition = build(:consultation, access_limiting: "organisations")
    edition.stubs(:historic?).returns(false)
    edition.stubs(:access_limiting_organisations?).returns(true)
    edition.stubs(:organisations).returns([org])

    assert_not enforcer_for(user, edition).can?(:see)
  end

  test "grants access when user's organisation is in access_limiting_organisations and flag is on" do
    feature_flags.switch! :access_limiting_organisations_ui, true

    user = user_in(org)
    edition = build(:edition, access_limiting: "organisations")
    edition.stubs(:historic?).returns(false)
    edition.stubs(:access_limiting_organisations?).returns(true)
    edition.stubs(:access_limiting_organisations).returns([org])

    assert enforcer_for(user, edition).can?(:see)
  end

  test "revokes access when the user's organisation is not in access_limiting_organisations and flag is on" do
    feature_flags.switch! :access_limiting_organisations_ui, true

    user = user_in(org)
    edition = build(:edition, access_limiting: "organisations")
    edition.stubs(:historic?).returns(false)
    edition.stubs(:access_limiting_organisations?).returns(true)
    edition.stubs(:access_limiting_organisations).returns([other_org])

    assert_not enforcer_for(user, edition).can?(:see)
  end

  test "revokes access when the user does not have an organisation, and flag is on" do
    feature_flags.switch! :access_limiting_organisations_ui, true

    user = user_in(nil)
    edition = build(:edition, access_limiting: "organisations")
    edition.stubs(:historic?).returns(false)
    edition.stubs(:access_limiting_organisations?).returns(true)
    edition.stubs(:access_limiting_organisations).returns([org])

    assert_not enforcer_for(user, edition).can?(:see)
  end

  test "revokes access when access_limiting is 'organisations' but access_limiting_organisations is empty, and flag is on" do
    feature_flags.switch! :access_limiting_organisations_ui, true

    user = user_in(org)
    edition = build(:edition, access_limiting: "organisations")
    edition.stubs(:historic?).returns(false)
    edition.stubs(:access_limiting_organisations?).returns(true)
    edition.stubs(:access_limiting_organisations).returns([])

    assert_not enforcer_for(user, edition).can?(:see)
  end

  test "any user can :see a historic edition that is not access-limited" do
    user = user_in(org)
    assert enforcer_for(user, historic_unrestricted_edition).can?(:see)
  end

  test "a regular user cannot :update a historic edition that is not access-limited" do
    user = user_in(org)
    assert_not enforcer_for(user, historic_unrestricted_edition).can?(:update)
  end

  test "a gds_editor can :update a historic edition that is not access-limited" do
    user = user_in(org, gds_editor?: true)
    assert enforcer_for(user, historic_unrestricted_edition).can?(:update)
  end

  test "a gds_admin can :update a historic edition that is not access-limited" do
    user = user_in(org, gds_admin?: true)
    assert enforcer_for(user, historic_unrestricted_edition).can?(:update)
  end

  test "a historic_content_unpublisher can :unpublish a historic edition that is not access-limited" do
    user = user_in(org, can_unpublish_historic_content?: true)
    assert enforcer_for(user, historic_unrestricted_edition).can?(:unpublish)
  end

  test "a regular user cannot :unpublish a historic edition that is not access-limited" do
    user = user_in(org)
    assert_not enforcer_for(user, historic_unrestricted_edition).can?(:unpublish)
  end

  test "a user in the limiting org can :see an access-limited historic edition" do
    user = user_in(org)
    assert enforcer_for(user, historic_access_limited_edition([org])).can?(:see)
  end

  test "a user NOT in the limiting org cannot :see an access-limited historic edition" do
    user = user_in(org)
    assert_not enforcer_for(user, historic_access_limited_edition([other_org])).can?(:see)
  end

  test "a user NOT in the limiting org cannot perform ANY action on an access-limited historic edition" do
    user = user_in(org)
    edition = historic_access_limited_edition([other_org])
    enforcer = enforcer_for(user, edition)

    Whitehall::Authority::Rules::EditionRules.actions.each do |action|
      assert_not enforcer.can?(action),
                 "expected user outside limiting org to be denied :#{action} on access-limited historic edition"
    end
  end

  test "a gds_editor outside the limiting org cannot :see an access-limited historic edition" do
    user = user_in(org, gds_editor?: true)
    assert_not enforcer_for(user, historic_access_limited_edition([other_org])).can?(:see)
  end

  test "a gds_admin outside the limiting org cannot :see an access-limited historic edition" do
    user = user_in(org, gds_admin?: true)
    assert_not enforcer_for(user, historic_access_limited_edition([other_org])).can?(:see)
  end

  test "a gds_editor inside the limiting org can :update an access-limited historic edition" do
    user = user_in(org, gds_editor?: true)
    assert enforcer_for(user, historic_access_limited_edition([org])).can?(:update)
  end

  test "a gds_admin inside the limiting org can :update an access-limited historic edition" do
    user = user_in(org, gds_admin?: true)
    assert enforcer_for(user, historic_access_limited_edition([org])).can?(:update)
  end

  test "a historic_content_unpublisher inside the limiting org can :unpublish an access-limited historic edition" do
    user = user_in(org, can_unpublish_historic_content?: true)
    assert enforcer_for(user, historic_access_limited_edition([org])).can?(:unpublish)
  end
  
  test "a historic_content_unpublisher NOT in the limiting org cannot :unpublish an access-limited historic edition" do
    user = user_in(org, can_unpublish_historic_content?: true)
    assert_not enforcer_for(user, historic_access_limited_edition([other_org])).can?(:unpublish)
  end

  test "a user NOT in access_limiting_organisations cannot :see an access-limited historic edition when flag is on" do
    feature_flags.switch! :access_limiting_organisations_ui, true

    user = user_in(org)
    edition = build(:published_edition, force_published: true)
    edition.stubs(:historic?).returns(true)
    edition.stubs(:access_limiting_organisations?).returns(true)
    edition.stubs(:access_limiting_organisations).returns([other_org])

    assert_not enforcer_for(user, edition).can?(:see)
  end

  test "a user in access_limiting_organisations can :see an access-limited historic edition when flag is on" do
    feature_flags.switch! :access_limiting_organisations_ui, true

    user = user_in(org)
    edition = build(:published_edition, force_published: true)
    edition.stubs(:historic?).returns(true)
    edition.stubs(:access_limiting_organisations?).returns(true)
    edition.stubs(:access_limiting_organisations).returns([org])

    assert enforcer_for(user, edition).can?(:see)
  end
end
