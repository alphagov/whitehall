
require "test_helper"

class ExportNewsDocumentTest < ActiveSupport::TestCase
  test "returns a hash representation of a document" do
    document = FactoryBot.build(:edition, :with_document).document
    export = ExportNewsDocument.new(document).as_json
    assert_instance_of Hash, export
  end
end
