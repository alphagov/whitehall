require 'test_helper'

class DocumentSourceTest < ActiveSupport::TestCase

  test 'should be invalid without a url' do
    document_source = build(:document_source, url: nil)
    refute document_source.valid?
  end

end
