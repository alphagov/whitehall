require 'test_helper'

class DocumentHelperTest < ActionView::TestCase
  test '#document_organisation_class returns slug of first document organisation' do
    organisations = [create(:organisation), create(:organisation)]
    document = create(:document, organisations: organisations)
    assert_equal organisations.first.slug, document_organisation_class(document)
  end

  test '#document_organisation_class returns "no_organisation" if doc has no organisation' do
    document = create(:document)
    assert_equal 'unknown_organisation', document_organisation_class(document)
  end
end
