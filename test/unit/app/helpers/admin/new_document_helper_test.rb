require "test_helper"

class Admin::NewDocumentHelperTest < ActionView::TestCase
  test "new_document_radio_item returns a hash representation of the document type" do
    assert_equal new_document_radio_item(NewsArticle), {
      value: "news_article",
      text: "News article",
      bold: true,
      hint_text: "Use this for news story, press release, government response, and world news story.",
    }
  end
end
