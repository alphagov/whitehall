require "test_helper"

class DocumentCollectionTest < ActiveSupport::TestCase
  test 'should be invalid without a name' do
    collection = build(:document_collection, name: nil)
    refute collection.valid?
  end
end
