require "test_helper"

class Admin::NewDocumentHelperTest < ActionView::TestCase
  class NewDocType; end

  test "radio_buttons_for returns a hash representation of the document types" do
    document_types = {
      "new_doc_type_with_no_hint" => { "klass" => NewDocType, "label" => "Custom visible label for doc type with no hint" },
      "new_doc_type_with_hint" => { "klass" => NewDocType, "label" => "Custom visible label for doc type with hint", "hint_text" => "Custom hint text for doc type with hint" },
    }

    assert_equal radio_buttons_for(document_types), [
      {
        value: "new_doc_type_with_no_hint",
        text: "Custom visible label for doc type with no hint",
        bold: true,
        hint_text: nil,
      },
      {
        value: "new_doc_type_with_hint",
        text: "Custom visible label for doc type with hint",
        bold: true,
        hint_text: "Custom hint text for doc type with hint",
      },
    ]
  end
end
