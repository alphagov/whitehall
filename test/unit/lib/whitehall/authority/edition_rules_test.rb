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

  def user_with_email(email)
    OpenStruct.new(
      id: 1,
      gds_editor?: false,
      email:,
    )
  end

  def org
    @org ||= build(:organisation)
  end

  def other_org
    @other_org ||= build(:organisation)
  end

  def historic_access_limited_edition_by_orgs(limiting_orgs)
    edition = build(:publication)
    edition.stubs(:historic?).returns(true)
    edition.stubs(:access_limiting_organisations?).returns(true)
    edition.stubs(:access_limiting_organisations).returns(limiting_orgs)
    edition.stubs(:organisations).returns(limiting_orgs)
    edition
  end

  def historic_access_limited_edition_by_individuals(allowed_emails)
    edition = build(:publication, access_limiting: "individuals")
    edition.stubs(:historic?).returns(true)
    edition.stubs(:access_limiting_individuals).returns(
      allowed_emails.map { |email| OpenStruct.new(email:) },
    )
    edition
  end

  def historic_unrestricted_edition
    edition = build(:edition)
    edition.stubs(:historic?).returns(true)
    edition.stubs(:access_limiting_organisations?).returns(false)
    edition
  end

  test "grants access based on lead/supporting organisations when flag is OFF" do
    feature_flags.switch! :access_limiting_organisations_ui, false

    user = user_in(org)
    edition = build(:consultation, access_limiting: "organisations")
    edition.stubs(:historic?).returns(false)
    edition.stubs(:access_limiting_organisations?).returns(true)
    edition.stubs(:access_limiting_organisations).returns([other_org])
    edition.stubs(:organisations).returns([org])

    assert enforcer_for(user, edition).can?(:see)
  end

  test "revokes access based on lead/supporting organisations when flag is OFF" do
    feature_flags.switch! :access_limiting_organisations_ui, false

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

  test "revokes access when the user does not have an organisation, and flag is OFF" do
    feature_flags.switch! :access_limiting_organisations_ui, false

    user = user_in(nil)
    edition = build(:consultation, access_limiting: "organisations")
    edition.stubs(:historic?).returns(false)
    edition.stubs(:access_limiting_organisations?).returns(true)
    edition.stubs(:organisations).returns([org])

    assert_not enforcer_for(user, edition).can?(:see)
  end

  test "grants access when user's organisation is in access_limiting_organisations and flag is ON" do
    feature_flags.switch! :access_limiting_organisations_ui, true

    user = user_in(org)
    edition = build(:edition, access_limiting: "organisations")
    edition.stubs(:historic?).returns(false)
    edition.stubs(:access_limiting_organisations?).returns(true)
    edition.stubs(:access_limiting_organisations).returns([org])

    assert enforcer_for(user, edition).can?(:see)
  end

  test "revokes access when the user's organisation is not in access_limiting_organisations and flag is ON" do
    feature_flags.switch! :access_limiting_organisations_ui, true

    user = user_in(org)
    edition = build(:edition, access_limiting: "organisations")
    edition.stubs(:historic?).returns(false)
    edition.stubs(:access_limiting_organisations?).returns(true)
    edition.stubs(:access_limiting_organisations).returns([other_org])

    assert_not enforcer_for(user, edition).can?(:see)
  end

  test "grants access when user's email is in access_limiting_individuals and flag is ON" do
    feature_flags.switch! :access_limiting_individuals_ui, true

    user = user_with_email("user@example.com")

    edition = build(:edition, access_limiting: "individuals")
    edition.stubs(:access_limiting_individuals).returns([OpenStruct.new(email: "user@example.com")])

    assert enforcer_for(user, edition).can?(:see)
  end

  test "grants access when user's email matches an access_limiting_individual case-insensitively and flag is ON" do
    feature_flags.switch! :access_limiting_individuals_ui, true

    user = user_with_email("user@example.com")

    edition = build(:edition, access_limiting: "individuals")
    edition.stubs(:access_limiting_individuals).returns([OpenStruct.new(email: "User@Example.com")])

    assert enforcer_for(user, edition).can?(:see)
  end

  test "revokes access when user's email is not in access_limiting_individuals and flag is ON" do
    feature_flags.switch! :access_limiting_individuals_ui, true

    user = user_with_email("user@example.com")

    edition = build(:edition, access_limiting: "individuals")
    edition.stubs(:access_limiting_individuals).returns([OpenStruct.new(email: "someone-else@example.com")])

    assert_not enforcer_for(user, edition).can?(:see)
  end

  test "revokes access when the user does not have an organisation, and flag is ON" do
    feature_flags.switch! :access_limiting_organisations_ui, true

    user = user_in(nil)
    edition = build(:edition, access_limiting: "organisations")
    edition.stubs(:historic?).returns(false)
    edition.stubs(:access_limiting_organisations?).returns(true)
    edition.stubs(:access_limiting_organisations).returns([org])

    assert_not enforcer_for(user, edition).can?(:see)
  end

  test "revokes access when access_limiting is 'organisations' but access_limiting_organisations is empty, and flag is ON" do
    feature_flags.switch! :access_limiting_organisations_ui, true

    user = user_in(org)
    edition = build(:edition, access_limiting: "organisations")
    edition.stubs(:historic?).returns(false)
    edition.stubs(:access_limiting_organisations?).returns(true)
    edition.stubs(:access_limiting_organisations).returns([])

    assert_not enforcer_for(user, edition).can?(:see)
  end

  test "revokes access when access_limiting it set to 'individuals', but there are no access_limiting_individuals on the edition, and flag is ON" do
    feature_flags.switch! :access_limiting_individuals_ui, true

    org1 = build(:organisation)
    user = user_in(org1)

    edition = build(:edition, access_limiting: "individuals")
    edition.stubs(:access_limiting_individuals).returns([])

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

  test "a GDS Editor can :update a historic edition that is not access-limited" do
    user = user_in(org, gds_editor?: true)
    assert enforcer_for(user, historic_unrestricted_edition).can?(:update)
  end

  test "a GDS Admin can :update a historic edition that is not access-limited" do
    user = user_in(org, gds_admin?: true)
    assert enforcer_for(user, historic_unrestricted_edition).can?(:update)
  end

  test "a Historic Content Unpublisher can :unpublish a historic edition that is not access-limited" do
    user = user_in(org, can_unpublish_historic_content?: true)
    assert enforcer_for(user, historic_unrestricted_edition).can?(:unpublish)
  end

  test "a regular user cannot :unpublish a historic edition that is not access-limited" do
    user = user_in(org)
    assert_not enforcer_for(user, historic_unrestricted_edition).can?(:unpublish)
  end

  test "a user in the limiting org can :see an access-limited historic edition" do
    user = user_in(org)
    assert enforcer_for(user, historic_access_limited_edition_by_orgs([org])).can?(:see)
  end

  test "a user NOT in the limiting org cannot :see an access-limited historic edition" do
    user = user_in(org)
    assert_not enforcer_for(user, historic_access_limited_edition_by_orgs([other_org])).can?(:see)
  end

  test "a user NOT in the limiting org cannot perform ANY action on an access-limited historic edition" do
    user = user_in(org)
    edition = historic_access_limited_edition_by_orgs([other_org])
    enforcer = enforcer_for(user, edition)

    Whitehall::Authority::Rules::EditionRules.actions.each do |action|
      assert_not enforcer.can?(action),
                 "expected user outside limiting org to be denied :#{action} on access-limited historic edition"
    end
  end

  test "a GDS Editor outside the limiting org cannot :see an access-limited historic edition" do
    user = user_in(org, gds_editor?: true)
    assert_not enforcer_for(user, historic_access_limited_edition_by_orgs([other_org])).can?(:see)
  end

  test "a GDS Admin outside the limiting org cannot :see an access-limited historic edition" do
    user = user_in(org, gds_admin?: true)
    assert_not enforcer_for(user, historic_access_limited_edition_by_orgs([other_org])).can?(:see)
  end

  test "a GDS Editor inside the limiting org can :update an access-limited historic edition" do
    user = user_in(org, gds_editor?: true)
    assert enforcer_for(user, historic_access_limited_edition_by_orgs([org])).can?(:update)
  end

  test "a GDS Admin inside the limiting org can :update an access-limited historic edition" do
    user = user_in(org, gds_admin?: true)
    assert enforcer_for(user, historic_access_limited_edition_by_orgs([org])).can?(:update)
  end

  test "a Historic Content Unpublisher inside the limiting org can :unpublish an access-limited historic edition" do
    user = user_in(org, can_unpublish_historic_content?: true)
    assert enforcer_for(user, historic_access_limited_edition_by_orgs([org])).can?(:unpublish)
  end

  test "a Historic Content Unpublisher NOT in the limiting org cannot :unpublish an access-limited historic edition" do
    user = user_in(org, can_unpublish_historic_content?: true)
    assert_not enforcer_for(user, historic_access_limited_edition_by_orgs([other_org])).can?(:unpublish)
  end

  test "a user NOT in access_limiting_organisations cannot :see an access-limited historic edition when flag is ON" do
    feature_flags.switch! :access_limiting_organisations_ui, true

    user = user_in(org)
    edition = build(:published_edition, force_published: true)
    edition.stubs(:historic?).returns(true)
    edition.stubs(:access_limiting_organisations?).returns(true)
    edition.stubs(:access_limiting_organisations).returns([other_org])

    assert_not enforcer_for(user, edition).can?(:see)
  end

  test "a user in access_limiting_organisations can :see an access-limited historic edition when flag is ON" do
    feature_flags.switch! :access_limiting_organisations_ui, true

    user = user_in(org)
    edition = build(:published_edition, force_published: true)
    edition.stubs(:historic?).returns(true)
    edition.stubs(:access_limiting_organisations?).returns(true)
    edition.stubs(:access_limiting_organisations).returns([org])

    assert enforcer_for(user, edition).can?(:see)
  end

  test "a user outside the limiting org cannot perform ANY action on a non-historic access-limited edition when flag is OFF" do
    feature_flags.switch! :access_limiting_organisations_ui, false

    user = user_in(other_org)
    edition = build(:consultation, access_limiting: "organisations")
    edition.stubs(:historic?).returns(false)
    edition.stubs(:access_limiting_organisations?).returns(true)
    edition.stubs(:organisations).returns([org])

    enforcer = enforcer_for(user, edition)
    Whitehall::Authority::Rules::EditionRules.actions.each do |action|
      assert_not enforcer.can?(action),
                 "expected user outside limiting org to be denied :#{action} on access-limited edition when flag is OFF"
    end
  end

  test "a user outside the limiting org cannot perform ANY action on a non-historic access-limited edition when flag is ON" do
    feature_flags.switch! :access_limiting_organisations_ui, true

    user = user_in(other_org)
    edition = build(:edition, access_limiting: "organisations")
    edition.stubs(:historic?).returns(false)
    edition.stubs(:access_limiting_organisations?).returns(true)
    edition.stubs(:access_limiting_organisations).returns([org])

    enforcer = enforcer_for(user, edition)
    Whitehall::Authority::Rules::EditionRules.actions.each do |action|
      assert_not enforcer.can?(action), "expected user outside limiting org to be denied :#{action} on access-limited edition when flag is ON"
    end
  end

  test "a user NOT in access_limiting_individuals cannot perform ANY action on a non-historic edition when flag is ON" do
    feature_flags.switch! :access_limiting_individuals_ui, true

    user = user_with_email("outsider@example.com")
    edition = build(:edition, access_limiting: "individuals")
    edition.stubs(:historic?).returns(false)
    edition.stubs(:access_limiting_individuals).returns([OpenStruct.new(email: "insider@example.com")])

    enforcer = enforcer_for(user, edition)
    Whitehall::Authority::Rules::EditionRules.actions.each do |action|
      assert_not enforcer.can?(action), "expected user not in access_limiting_individuals to be denied :#{action}"
    end
  end

  test "when the access_limiting_individuals_ui flag is OFF, individuals mode does not enforce access" do
    feature_flags.switch! :access_limiting_individuals_ui, false

    user = user_with_email("anyone@example.com")
    edition = build(:edition, access_limiting: "individuals")
    edition.stubs(:historic?).returns(false)
    edition.stubs(:access_limiting_organisations?).returns(false)

    assert enforcer_for(user, edition).can?(:see)
  end

  test "a user whose email is in access_limiting_individuals can see a historic edition when flag is ON" do
    feature_flags.switch! :access_limiting_individuals_ui, true

    user = user_with_email("insider@example.com")
    assert enforcer_for(user, historic_access_limited_edition_by_individuals(["insider@example.com"])).can?(:see)
  end

  test "a user whose email is NOT in access_limiting_individuals cannot :see a historic edition when flag is ON" do
    feature_flags.switch! :access_limiting_individuals_ui, true

    user = user_with_email("outsider@example.com")
    assert_not enforcer_for(user, historic_access_limited_edition_by_individuals(["insider@example.com"])).can?(:see)
  end

  test "a user NOT in access_limiting_individuals cannot perform ANY action on a historic edition when flag is ON" do
    feature_flags.switch! :access_limiting_individuals_ui, true

    user = user_with_email("outsider@example.com")
    edition = historic_access_limited_edition_by_individuals(["insider@example.com"])

    enforcer = enforcer_for(user, edition)
    Whitehall::Authority::Rules::EditionRules.actions.each do |action|
      assert_not enforcer.can?(action), "expected user not in access_limiting_individuals to be denied :#{action} on access-limited historic edition"
    end
  end

  test "a GDS Editor whose email is NOT in access_limiting_individuals cannot :see a historic edition when flag is ON" do
    feature_flags.switch! :access_limiting_individuals_ui, true

    user = user_in(org, gds_editor?: true, email: "gds@example.com")
    assert_not enforcer_for(user, historic_access_limited_edition_by_individuals(["insider@example.com"])).can?(:see)
  end

  test "a GDS Admin whose email is NOT in access_limiting_individuals cannot :see a historic edition when flag is ON" do
    feature_flags.switch! :access_limiting_individuals_ui, true

    user = user_in(org, gds_admin?: true, email: "gds@example.com")
    assert_not enforcer_for(user, historic_access_limited_edition_by_individuals(["insider@example.com"])).can?(:see)
  end

  test "a GDS Editor whose email is in access_limiting_individuals can :update a historic edition when flag is ON" do
    feature_flags.switch! :access_limiting_individuals_ui, true

    user = user_in(org, gds_editor?: true, email: "gds@example.com")
    assert enforcer_for(user, historic_access_limited_edition_by_individuals(["gds@example.com"])).can?(:update)
  end
end
