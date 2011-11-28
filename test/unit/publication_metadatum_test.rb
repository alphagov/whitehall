require "test_helper"

class PublicationMetadatumTest < ActiveSupport::TestCase
  test 'should be valid without any attributes' do
    metadatum = PublicationMetadatum.new
    assert metadatum.valid?
  end
end
