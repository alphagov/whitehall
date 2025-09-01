require "test_helper"

class ConfigurableDocumentTypeRulesTest < ActiveSupport::TestCase
  setup do
    @organisation = create(:organisation)
    @type_key = "test_type"
    @no_organisations_type_key = "test_type_without_orgs"
    test_type_with_user_organisation =
      build_configurable_document_type(
        @type_key, {
          "settings" => {
            "organisations" => [@organisation.content_id],
          },
        }
      )
    test_type_with_no_organisation =
      build_configurable_document_type(
        @no_organisations_type_key, {
          "settings" => {
            "organisations" => nil,
          },
        }
      )
    ConfigurableDocumentType.setup_test_types(test_type_with_user_organisation.merge(test_type_with_no_organisation))
  end

  test "user can create an edition if the document type is managed by their organisation" do
    user = User.new(organisation_slug: @organisation.slug)
    type = ConfigurableDocumentType.find(@type_key)
    assert Whitehall::Authority::Enforcer.new(user, type).can?(:create)
  end

  test "user can not create an edition if the document type is not managed by their organisation" do
    other_organisation = create(:organisation)
    user = User.new(organisation_slug: other_organisation.slug)
    type = ConfigurableDocumentType.find(@type_key)
    assert_not Whitehall::Authority::Enforcer.new(user, type).can?(:create)
  end
end
