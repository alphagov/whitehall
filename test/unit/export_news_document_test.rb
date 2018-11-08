require "test_helper"

class ExportNewsDocumentTest < ActiveSupport::TestCase
  test "returns a hash representation of a document" do
    document = FactoryBot.create(:news_article, :with_document).document
    export = ExportNewsDocument.new(document).call
    assert_instance_of Hash, export
    assert export["editions"].count == 1
  end

  test "includes a mapping of contact ids to contact content_ids embedded" do
    contact = FactoryBot.create(:contact, content_id: SecureRandom.uuid)
    document = FactoryBot.create(:news_article,
                                 :with_document,
                                 body: "[Contact:#{contact.id}]").document
    export = ExportNewsDocument.new(document).call
    assert_equal export["contacts"], contact.id.to_s => contact.content_id
  end
end
