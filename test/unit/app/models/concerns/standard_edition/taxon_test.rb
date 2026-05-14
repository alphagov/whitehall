require "test_helper"

class StandardEdition::TaxonTest < ActiveSupport::TestCase
  test "requires_taxon? returns true when taxon is required for the document type" do
    test_type = build_configurable_document_type("test_type_with_taxon_required", {
      "settings" => {
        "taxon_required" => true,
      },
    })
    ConfigurableDocumentType.setup_test_types(test_type)

    edition = create(:standard_edition, configurable_document_type: "test_type_with_taxon_required")

    assert edition.requires_taxon?
  end

  test "requires_taxon? returns false when taxon is not required for the document type" do
    test_type = build_configurable_document_type("test_type_with_taxon_not_required", {
      "settings" => {
        "taxon_required" => false,
      },
    })
    ConfigurableDocumentType.setup_test_types(test_type)

    edition = create(:standard_edition, configurable_document_type: "test_type_with_taxon_not_required")

    assert_not edition.requires_taxon?
  end
end
