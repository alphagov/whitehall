require_relative "authority_test_helper"
require "ostruct"

class GDSAdminTest < ActiveSupport::TestCase
  def gds_admin(id = 1)
    OpenStruct.new(id:, gds_admin?: true, organisation: build(:organisation))
  end

  def non_gds_admin(id = 2)
    OpenStruct.new(id:, gds_admin?: false, organisation: build(:organisation))
  end

  include AuthorityTestHelper

  test "non gds admin cannot create a new organisation" do
    assert_not enforcer_for(non_gds_admin, Organisation).can?(:create)
  end

  test "gds admin can create a new organisation" do
    assert enforcer_for(gds_admin, Organisation).can?(:create)
  end

  test "can export editions" do
    assert enforcer_for(gds_admin, Edition).can?(:export)
  end

  test "can manage governments" do
    _government = Government.new
    assert enforcer_for(gds_admin, Government).can?(:manage)

    assert_not enforcer_for(non_gds_admin, Government).can?(:manage)
  end

  test "can mark editions as political" do
    assert enforcer_for(gds_admin, normal_edition).can?(:mark_political)
  end

  test "can do anything to historic editions" do
    Whitehall::Authority::Rules::EditionRules.actions.each do |action|
      assert enforcer_for(gds_admin, historic_edition).can?(action)
    end
  end

  test "can create social media accounts" do
    assert enforcer_for(gds_admin, build(:social_media_account)).can?(:create)
  end

  test "can update social media accounts" do
    assert enforcer_for(gds_admin, build(:social_media_account)).can?(:update)
  end

  test "can delete social media accounts" do
    assert enforcer_for(gds_admin, build(:social_media_account)).can?(:delete)
  end

  test "cannot do anything to an access-limited historic edition if not in the limiting org" do
    org = build(:organisation)
    other_org = build(:organisation)
    user = gds_admin
    user.stubs(:organisation).returns(org)

    edition = build(:publication, :published)
    edition.stubs(:historic?).returns(true)
    edition.stubs(:access_limiting_organisations?).returns(true)
    edition.stubs(:access_limiting_organisations).returns([other_org])
    edition.stubs(:organisations).returns([other_org])

    Whitehall::Authority::Rules::EditionRules.actions.each do |action|
      assert_not enforcer_for(user, edition).can?(action),
                 "expected gds_admin outside limiting org to be denied :#{action} on access-limited historic edition"
    end
  end

  test "can :see an access-limited historic edition if in the limiting org" do
    org = build(:organisation)
    user = gds_admin
    user.stubs(:organisation).returns(org)

    edition = build(:publication, :published)
    edition.stubs(:historic?).returns(true)
    edition.stubs(:access_limiting_organisations?).returns(true)
    edition.stubs(:access_limiting_organisations).returns([org])
    edition.stubs(:organisations).returns([org])

    assert enforcer_for(user, edition).can?(:see)
  end
end
