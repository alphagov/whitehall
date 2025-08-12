require "test_helper"

class FlexiblePageRulesTest < ActiveSupport::TestCase
  setup do
    @organisation = create(:organisation)
    @type_key = "test_type"
    @no_organisations_type_key = "test_type_without_orgs"
    test_types = {
      "test_type" => {
        "key" => @type_key,
        "schema" => {
          "$schema": "https://json-schema.org/draft/2020-12/schema",
          "$id": "https://www.gov.uk/schemas/test_type/v1",
          "title": "Test type",
          "type": "object",
          "properties" => {
            "test_attribute" => {
              "title" => "Test attribute",
              "type" => "string",
            },
          },
        },
        "settings" => {
          "organisations" => [@organisation.content_id],
        },
      },
      "test_type_without_orgs" => {
        "key" => @no_organisations_type_key,
        "schema" => {
          "$schema": "https://json-schema.org/draft/2020-12/schema",
          "$id": "https://www.gov.uk/schemas/test_type/v1",
          "title": "Test type without orgs",
          "type": "object",
          "properties" => {
            "test_attribute" => {
              "title" => "Test attribute",
              "type" => "string",
            },
          },
        },
        "settings" => {
          "organisations" => nil,
        },
      },
    }
    FlexiblePageType.setup_test_types(test_types)
  end

  test "user can see a flexible page if the flexible page type is managed by their organisation" do
    user = User.new(organisation: @organisation)
    page = FlexiblePage.new(flexible_page_type: @type_key)
    assert Whitehall::Authority::Enforcer.new(user, page).can?(:see)
  end

  test "user can not see a flexible page if the flexible page type is not managed by their organisation" do
    user = User.new(organisation: create(:organisation))
    page = FlexiblePage.new(flexible_page_type: @type_key)
    assert_not Whitehall::Authority::Enforcer.new(user, page).can?(:see)
  end

  test "normal edition rules are applied for actions requiring higher privileges" do
    user = User.new(organisation: @organisation)
    page = FlexiblePage.new(flexible_page_type: @type_key)
    assert_not Whitehall::Authority::Enforcer.new(user, page).can?(:force_publish)
  end

  test "normal edition rules are applied when the flexible page type is not limited to specific organisations" do
    user = User.new(organisation: create(:organisation))
    page = FlexiblePage.new(flexible_page_type: @no_organisations_type_key)
    assert Whitehall::Authority::Enforcer.new(user, page).can?(:see)
  end

  test "cannot do anything to a flexible page if they do not belong to a permitted organisation" do
    user = User.new(organisation: create(:organisation))
    page = FlexiblePage.new(flexible_page_type: @type_key)
    enforcer = Whitehall::Authority::Enforcer.new(user, page)

    Whitehall::Authority::Rules::EditionRules.actions.each do |action|
      assert_not enforcer.can?(action)
    end
  end
end
