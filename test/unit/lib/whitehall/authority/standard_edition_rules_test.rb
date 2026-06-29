require "test_helper"

class StandardEditionRulesTest < ActiveSupport::TestCase
  setup do
    @organisation = create(:organisation)
    @other_organisation = create(:organisation)

    ConfigurableDocumentType.setup_test_types(
      "test_type" => {
        "key" => "test_type",
        "title" => "Test type",
        "schema" => { "properties" => { "test_attribute" => { "title" => "Test attribute", "type" => "string" } } },
        "settings" => { "organisations" => [@organisation.content_id] },
      },
      "test_type_without_orgs" => {
        "key" => "test_type_without_orgs",
        "title" => "Test type without orgs",
        "schema" => { "properties" => { "test_attribute" => { "title" => "Test attribute", "type" => "string" } } },
        "settings" => { "organisations" => nil },
      },
    )
  end

  def gds_editor_in(organisation)
    OpenStruct.new(id: 1, gds_editor?: true, gds_admin?: false, organisation:)
  end

  def historic_standard_edition
    page = build(:standard_edition, configurable_document_type: "test_type")
    page.stubs(:historic?).returns(true)
    page.stubs(:access_limiting_organisations?).returns(false)
    page
  end

  def historic_access_limited_standard_edition(limiting_orgs)
    page = build(:standard_edition, configurable_document_type: "test_type")
    page.stubs(:historic?).returns(true)
    page.stubs(:access_limiting_organisations?).returns(true)
    page.stubs(:access_limiting_organisations).returns(limiting_orgs)
    page.stubs(:organisations).returns(limiting_orgs)
    page
  end

  test "user can see an edition if the document type is managed by their organisation" do
    user = User.new(organisation: @organisation)
    page = build(:standard_edition, configurable_document_type: "test_type")
    assert Whitehall::Authority::Enforcer.new(user, page).can?(:see)
  end

  test "user cannot see an edition if the document type is not managed by their organisation" do
    user = User.new(organisation: @other_organisation)
    page = build(:standard_edition, configurable_document_type: "test_type")
    assert_not Whitehall::Authority::Enforcer.new(user, page).can?(:see)
  end

  test "normal edition rules are applied for actions requiring higher privileges" do
    user = User.new(organisation: @organisation)
    page = build(:standard_edition, configurable_document_type: "test_type")
    assert_not Whitehall::Authority::Enforcer.new(user, page).can?(:force_publish)
  end

  test "normal edition rules are applied when the document type is not limited to specific organisations" do
    user = User.new(organisation: @other_organisation)
    page = build(:standard_edition, configurable_document_type: "test_type_without_orgs")
    assert Whitehall::Authority::Enforcer.new(user, page).can?(:see)
  end

  test "cannot do anything to an edition if they do not belong to a permitted organisation" do
    user = User.new(organisation: @other_organisation)
    page = build(:standard_edition, configurable_document_type: "test_type")
    enforcer = Whitehall::Authority::Enforcer.new(user, page)

    Whitehall::Authority::Rules::EditionRules.actions.each do |action|
      assert_not enforcer.can?(action),
                 "expected user outside permitted org to be denied :#{action}"
    end
  end

  test "any user can :see a historic standard edition that is not access-limited" do
    user = User.new(organisation: @other_organisation)
    assert Whitehall::Authority::Enforcer.new(user, historic_standard_edition).can?(:see)
  end

  test "a regular user cannot :update a historic standard edition" do
    user = create(:user, organisation: @organisation)
    assert_not Whitehall::Authority::Enforcer.new(user, historic_standard_edition).can?(:update)
  end

  test "a gds_editor can :update a historic standard edition" do
    user = gds_editor_in(@organisation)
    assert Whitehall::Authority::Enforcer.new(user, historic_standard_edition).can?(:update)
  end

  test "user inside the limiting org can :see an access-limited historic standard edition" do
    user = User.new(organisation: @organisation)
    assert Whitehall::Authority::Enforcer.new(
      user, historic_access_limited_standard_edition([@organisation])
    ).can?(:see)
  end

  test "user outside the limiting org cannot :see an access-limited historic standard edition" do
    user = User.new(organisation: @other_organisation)
    assert_not Whitehall::Authority::Enforcer.new(
      user, historic_access_limited_standard_edition([@organisation])
    ).can?(:see)
  end

  test "user outside the limiting org cannot perform any action on an access-limited historic standard edition" do
    user = User.new(organisation: @other_organisation)
    edition = historic_access_limited_standard_edition([@organisation])
    enforcer = Whitehall::Authority::Enforcer.new(user, edition)

    Whitehall::Authority::Rules::EditionRules.actions.each do |action|
      assert_not enforcer.can?(action),
                 "expected user outside limiting org to be denied :#{action} on access-limited historic standard edition"
    end
  end

  test "a gds_editor outside the limiting org cannot :see an access-limited historic standard edition" do
    user = gds_editor_in(@other_organisation)
    assert_not Whitehall::Authority::Enforcer.new(
      user, historic_access_limited_standard_edition([@organisation])
    ).can?(:see)
  end

  test "a gds_editor inside the limiting org can :see an access-limited historic standard edition" do
    user = gds_editor_in(@organisation)
    assert Whitehall::Authority::Enforcer.new(
      user, historic_access_limited_standard_edition([@organisation])
    ).can?(:see)
  end
end