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

  def user_with_email(email, organisation:)
    OpenStruct.new(
      id: 1,
      gds_editor?: false,
      gds_admin?: false,
      can_unpublish_historic_content?: false,
      organisation:,
      email:,
    )
  end

  def historic_standard_edition
    page = build(:standard_edition, configurable_document_type: "test_type")
    page.stubs(:historic?).returns(true)
    page.stubs(:access_limiting_organisations?).returns(false)
    page
  end

  def historic_access_limited_standard_edition_by_orgs(limiting_orgs)
    page = build(:standard_edition, configurable_document_type: "test_type")
    page.stubs(:historic?).returns(true)
    page.stubs(:access_limiting_organisations?).returns(true)
    page.stubs(:access_limiting_organisations).returns(limiting_orgs)
    page.stubs(:organisations).returns(limiting_orgs)
    page
  end

  def historic_access_limited_standard_edition_by_individuals(allowed_emails)
    page = build(:standard_edition, configurable_document_type: "test_type", access_limiting: "individuals")
    page.stubs(:historic?).returns(true)
    page.stubs(:access_limiting_individuals?).returns(true)
    page.stubs(:access_limiting_individuals).returns(
      allowed_emails.map { |email| OpenStruct.new(email:) },
    )
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

  test "a GDS Editor can :update a historic standard edition" do
    user = gds_editor_in(@organisation)
    assert Whitehall::Authority::Enforcer.new(user, historic_standard_edition).can?(:update)
  end

  test "user inside the limiting org can :see an access-limited historic standard edition" do
    user = User.new(organisation: @organisation)
    assert Whitehall::Authority::Enforcer.new(
      user, historic_access_limited_standard_edition_by_orgs([@organisation])
    ).can?(:see)
  end

  test "user outside the limiting org cannot :see an access-limited historic standard edition" do
    user = User.new(organisation: @other_organisation)
    assert_not Whitehall::Authority::Enforcer.new(
      user, historic_access_limited_standard_edition_by_orgs([@organisation])
    ).can?(:see)
  end

  test "user outside the limiting org cannot perform any action on an access-limited historic standard edition" do
    user = User.new(organisation: @other_organisation)
    edition = historic_access_limited_standard_edition_by_orgs([@organisation])
    enforcer = Whitehall::Authority::Enforcer.new(user, edition)

    Whitehall::Authority::Rules::EditionRules.actions.each do |action|
      assert_not enforcer.can?(action),
                 "expected user outside limiting org to be denied :#{action} on access-limited historic standard edition"
    end
  end

  test "a GDS Editor outside the limiting org cannot :see an access-limited historic standard edition" do
    user = gds_editor_in(@other_organisation)
    assert_not Whitehall::Authority::Enforcer.new(
      user, historic_access_limited_standard_edition_by_orgs([@organisation])
    ).can?(:see)
  end

  test "a GDS Editor inside the limiting org can :see an access-limited historic standard edition" do
    user = gds_editor_in(@organisation)
    assert Whitehall::Authority::Enforcer.new(
      user, historic_access_limited_standard_edition_by_orgs([@organisation])
    ).can?(:see)
  end

  test "user in access_limiting_organisations can :see a non-historic standard edition when flag is ON" do
    feature_flags.switch! :access_limiting_organisations_ui, true

    user = User.new(organisation: @organisation)
    page = build(:standard_edition, configurable_document_type: "test_type", access_limiting: "organisations")
    page.stubs(:historic?).returns(false)
    page.stubs(:access_limiting_organisations?).returns(true)
    page.stubs(:access_limiting_organisations).returns([@organisation])

    assert Whitehall::Authority::Enforcer.new(user, page).can?(:see)
  end

  test "user NOT in access_limiting_organisations cannot :see a non-historic standard edition when flag is ON" do
    feature_flags.switch! :access_limiting_organisations_ui, true

    user = User.new(organisation: @organisation)
    page = build(:standard_edition, configurable_document_type: "test_type", access_limiting: "organisations")
    page.stubs(:historic?).returns(false)
    page.stubs(:access_limiting_organisations?).returns(true)
    page.stubs(:access_limiting_organisations).returns([@other_organisation])

    assert_not Whitehall::Authority::Enforcer.new(user, page).can?(:see)
  end

  test "user whose email IS in access_limiting_individuals can :see a non-historic standard edition when flag is ON" do
    feature_flags.switch! :access_limiting_individuals_ui, true

    user = User.new(organisation: @organisation, email: "insider@example.com")
    page = build(:standard_edition, configurable_document_type: "test_type", access_limiting: "individuals")
    page.stubs(:historic?).returns(false)
    page.stubs(:access_limiting_individuals).returns([OpenStruct.new(email: "insider@example.com")])

    assert Whitehall::Authority::Enforcer.new(user, page).can?(:see)
  end

  test "user whose email is NOT in access_limiting_individuals cannot :see a non-historic standard edition when flag is ON" do
    feature_flags.switch! :access_limiting_individuals_ui, true

    user = User.new(organisation: @organisation, email: "outsider@example.com")
    page = build(:standard_edition, configurable_document_type: "test_type", access_limiting: "individuals")
    page.stubs(:historic?).returns(false)
    page.stubs(:access_limiting_individuals).returns([OpenStruct.new(email: "insider@example.com")])

    assert_not Whitehall::Authority::Enforcer.new(user, page).can?(:see)
  end

  test "user NOT in access_limiting_individuals cannot perform ANY action on a non-historic standard edition when flag is ON" do
    feature_flags.switch! :access_limiting_individuals_ui, true

    user = User.new(organisation: @organisation, email: "outsider@example.com")
    page = build(:standard_edition, configurable_document_type: "test_type", access_limiting: "individuals")
    page.stubs(:historic?).returns(false)
    page.stubs(:access_limiting_individuals).returns([OpenStruct.new(email: "insider@example.com")])

    enforcer = Whitehall::Authority::Enforcer.new(user, page)
    Whitehall::Authority::Rules::EditionRules.actions.each do |action|
      assert_not enforcer.can?(action),
                 "expected user not in access_limiting_individuals to be denied :#{action} on standard edition"
    end
  end

  test "user whose email is in access_limiting_individuals can :see a historic standard edition when flag is ON" do
    feature_flags.switch! :access_limiting_individuals_ui, true

    user = user_with_email("insider@example.com", organisation: @organisation)
    assert Whitehall::Authority::Enforcer.new(
      user,
      historic_access_limited_standard_edition_by_individuals(["insider@example.com"]),
    ).can?(:see)
  end

  test "user whose email is NOT in access_limiting_individuals cannot :see a historic standard edition when flag is ON" do
    feature_flags.switch! :access_limiting_individuals_ui, true

    user = user_with_email("outsider@example.com", organisation: @other_organisation)
    assert_not Whitehall::Authority::Enforcer.new(
      user,
      historic_access_limited_standard_edition_by_individuals(["insider@example.com"]),
    ).can?(:see)
  end

  test "user NOT in access_limiting_individuals cannot perform ANY action on a historic standard edition when flag is ON" do
    feature_flags.switch! :access_limiting_individuals_ui, true

    user = user_with_email("outsider@example.com", organisation: @other_organisation)
    edition = historic_access_limited_standard_edition_by_individuals(["insider@example.com"])
    enforcer = Whitehall::Authority::Enforcer.new(user, edition)

    Whitehall::Authority::Rules::EditionRules.actions.each do |action|
      assert_not enforcer.can?(action),
                 "expected user not in access_limiting_individuals to be denied :#{action} on access-limited historic standard edition"
    end
  end

  test "a GDS Editor NOT in access_limiting_individuals cannot :see a historic standard edition when flag is ON" do
    feature_flags.switch! :access_limiting_individuals_ui, true

    user = OpenStruct.new(id: 1, gds_editor?: true, gds_admin?: false, email: "gds@example.com", organisation: @organisation)
    assert_not Whitehall::Authority::Enforcer.new(
      user,
      historic_access_limited_standard_edition_by_individuals(["insider@example.com"]),
    ).can?(:see)
  end

  test "a GDS Editor whose email IS in access_limiting_individuals can :update a historic standard edition when flag is ON" do
    feature_flags.switch! :access_limiting_individuals_ui, true

    user = OpenStruct.new(id: 1, gds_editor?: true, gds_admin?: false, email: "gds@example.com", organisation: @organisation)
    assert Whitehall::Authority::Enforcer.new(
      user,
      historic_access_limited_standard_edition_by_individuals(["gds@example.com"]),
    ).can?(:update)
  end
end
