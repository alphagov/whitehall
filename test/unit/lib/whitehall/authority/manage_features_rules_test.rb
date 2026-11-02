require_relative "authority_test_helper"

class ManageFeaturesRulesTest < ActiveSupport::TestCase
  include AuthorityTestHelper

  setup do
    @organisation = create(:organisation)
  end

  test "users in an organisation can manage its features" do
    assert enforcer_for(create(:writer, organisation: @organisation), @organisation).can?(:manage_features)
  end

  test "users outside an organisation cannot manage its features" do
    assert_not enforcer_for(create(:writer, organisation: create(:organisation)), @organisation).can?(:manage_features)
  end

  test "any user can manage world location news features" do
    world_location_news = build(:world_location_news)

    assert enforcer_for(create(:writer), world_location_news).can?(:manage_features)
  end

  test "users who cannot update a standard edition cannot manage its features" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
    edition = create(:draft_standard_edition, :access_limited_by_organisations, configurable_document_type: "test_type")
    user = create(:writer, organisation: create(:organisation))

    assert_not enforcer_for(user, edition).can?(:update)
    assert_not enforcer_for(user, edition).can?(:manage_features)
  end

  test "users who can update a standard edition can manage its features" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
    edition = create(:draft_standard_edition, configurable_document_type: "test_type")
    user = create(:writer, organisation: create(:organisation))

    assert enforcer_for(user, edition).can?(:update)
    assert enforcer_for(user, edition).can?(:manage_features)
  end
end
