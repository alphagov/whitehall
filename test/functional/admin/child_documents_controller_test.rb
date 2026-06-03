require "test_helper"

class Admin::ChildDocumentsControllerTest < ActionController::TestCase
  setup do
    parent_type = build_configurable_document_type("parent_type", {
      "settings" => {
        "allowed_child_document_types" => [
          {
            "document_type" => "child_type",
          },
        ],
      },
    })
    child_type = build_configurable_document_type("child_type")
    some_other_type = build_configurable_document_type("some_other_type")
    ConfigurableDocumentType.setup_test_types(parent_type.merge(child_type).merge(some_other_type))

    login_as :writer
  end

  should_be_an_admin_controller

  test "GET :choose_type renders successfully when permitted child document types exist" do
    parent_edition = create(
      :draft_standard_edition,
      configurable_document_type: "parent_type",
    )

    get :choose_type, params: { parent_edition_id: parent_edition.id }

    assert_response :success
    assert_not_nil assigns(:permitted_child_document_types)
  end

  test "GET :choose_type renders not found when no permitted child document types exist" do
    parent_edition = create(
      :draft_standard_edition,
      configurable_document_type: "some_other_type",
    )

    ConfigurableDocumentType
      .stubs(:allowed_child_document_types_of)
      .returns([])

    get :choose_type, params: { parent_edition_id: parent_edition.id }

    assert_response :not_found
    assert_template "admin/errors/not_found"
  end

  test "GET :choose_type filters child document types by user permissions" do
    parent_edition = create(
      :draft_standard_edition,
      configurable_document_type: "parent_type",
    )

    allowed_type = stub("allowed_type")
    forbidden_type = stub("forbidden_type")

    ConfigurableDocumentType
      .stubs(:allowed_child_document_types_of)
      .returns([allowed_type, forbidden_type])

    controller.stubs(:can?).returns(true)
    controller.stubs(:can?)
          .with(@current_user, forbidden_type)
          .returns(false)

    get :choose_type, params: { parent_edition_id: parent_edition.id }

    assert_response :success
    assert_equal [allowed_type], assigns(:permitted_child_document_types)
  end

  test "GET :choose_type renders not found when configurable document type is invalid" do
    StandardEdition
      .stubs(:find)
      .raises(ConfigurableDocumentType::NotFoundError)

    get :choose_type, params: { parent_edition_id: 123 }

    assert_response :not_found
    assert_template "admin/errors/not_found"
  end
end
