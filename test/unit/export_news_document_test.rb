require "test_helper"

class ExportNewsDocumentTest < ActiveSupport::TestCase
  test "returns a hash representation of a document" do
    document = FactoryBot.build(:edition, :with_document).document
    export = ExportNewsDocument.new(document).call
    assert_instance_of Hash, export
  end
end
