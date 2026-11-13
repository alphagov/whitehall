require "test_helper"

class StandardEdition::HasNavigationTest < ActiveSupport::TestCase
  test "allows_navigation? returns false when navigation is not supported on the document type" do
    test_type = build_configurable_document_type("test_type_without_navigation", {
      "settings" => {
        "navigation_enabled" => false,
      },
    })
    ConfigurableDocumentType.setup_test_types(test_type)

    edition = create(:standard_edition, configurable_document_type: "test_type_without_navigation")

    assert_not edition.allows_navigation?
  end

  test "allows_navigation? returns true when navigation is supported on the document type" do
    test_type = build_configurable_document_type("test_type_with_navigation", {
      "settings" => {
        "navigation_enabled" => true,
      },
    })
    ConfigurableDocumentType.setup_test_types(test_type)

    edition = create(:standard_edition, configurable_document_type: "test_type_with_navigation")

    assert edition.allows_navigation?
  end

  test "creates a navigation and navigation edition when a navigation-enabled edition is created" do
    test_type = build_configurable_document_type("test_type_with_navigation", {
      "settings" => {
        "navigation_enabled" => true,
      },
    })
    ConfigurableDocumentType.setup_test_types(test_type)

    edition = create(:standard_edition, configurable_document_type: "test_type_with_navigation")

    assert edition.navigation_edition.persisted?
    assert edition.navigation.content_id.present?
  end

  test "doesn't create a navigation when a navigation-disabled edition is created" do
    test_type = build_configurable_document_type("test_type_without_navigation", {
      "settings" => {
        "navigation_enabled" => false,
      },
    })
    ConfigurableDocumentType.setup_test_types(test_type)

    edition = create(:standard_edition, configurable_document_type: "test_type_without_navigation")

    assert_nil edition.navigation_edition
  end

  test "defines StandardEdition::HasNavigation::MAX_CHILD_PAGES_IN_NAV" do
    assert defined?(StandardEdition::HasNavigation::MAX_CHILD_PAGES_IN_NAV)
    assert_equal 7, StandardEdition::HasNavigation::MAX_CHILD_PAGES_IN_NAV
  end
end
