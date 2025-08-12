require "test_helper"

class FlexiblePageTypeRulesTest < ActiveSupport::TestCase
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

  test "user can create a flexible page if the flexible page type is managed by their organisation" do
    user = User.new(organisation_slug: @organisation.slug)
    type = FlexiblePageType.find(@type_key)
    assert Whitehall::Authority::Enforcer.new(user, type).can?(:create)
  end

  test "user can not create a flexible page if the flexible page type is not managed by their organisation" do
    other_organisation = create(:organisation)
    user = User.new(organisation_slug: other_organisation.slug)
    type = FlexiblePageType.find(@type_key)
    assert_not Whitehall::Authority::Enforcer.new(user, type).can?(:create)
  end
end
