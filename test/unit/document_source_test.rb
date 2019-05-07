require 'test_helper'

class DocumentSourceTest < ActiveSupport::TestCase
  test 'should be invalid without a url' do
    document_source = build(:document_source, url: nil)
    assert_not document_source.valid?
  end

  test 'should be invalid without a unique url' do
    existing_source = create(:document_source)
    new_source = build(:document_source, url: existing_source.url)
    assert_not new_source.valid?
  end
end
