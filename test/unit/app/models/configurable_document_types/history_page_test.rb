require "test_helper"

class HistoryPageTest < ActiveSupport::TestCase
  setup do
    @schema = ConfigurableDocumentType.find("history_page", bypass_cache: true).schema
  end

  test "validates the body field using SafeHtmlValidator" do
    assert @schema["validations"].key?("safe_html")
    assert @schema["validations"]["safe_html"]["attributes"].include?("body")
  end

  test "validates the body field length is within the database limits. See https://github.com/alphagov/whitehall/commit/a4aee78ac30bbc6587e19f554dd6168b592a3cc3" do
    assert @schema["validations"].key?("length")
    assert @schema["validations"]["length"]["attributes"].include?("body")
    assert_equal 16_777_215, @schema["validations"]["length"]["maximum"]
  end

  test "validates the body field contains no footnotes" do
    assert @schema["validations"].key?("no_footnotes_allowed")
    assert @schema["validations"]["no_footnotes_allowed"]["attributes"].include?("body")
  end

  test "validates the embedded contacts in the body field" do
    assert @schema["validations"].key?("embedded_contacts_exist")
    assert @schema["validations"]["embedded_contacts_exist"]["attributes"].include?("body")
  end
end
