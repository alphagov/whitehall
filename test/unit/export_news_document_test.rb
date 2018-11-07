require "test_helper"

class ExportNewsDocumentTest < ActiveSupport::TestCase
  test "returns a hash representation of a document" do
    document = FactoryBot.create(:news_article, :with_document).document
    export = ExportNewsDocument.new(document).call
    assert_instance_of Hash, export
    assert export["editions"].count == 1
  end
end
