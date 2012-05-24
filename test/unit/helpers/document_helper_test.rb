require 'test_helper'

class DocumentHelperTest < ActionView::TestCase
  test "#document_organisation_class returns the slug of the organisation of the first edition" do
    organisations = [create(:organisation), create(:organisation)]
    edition = create(:edition, organisations: organisations)
    assert_equal organisations.first.slug, document_organisation_class(edition)
  end

  test '#document_organisation_class returns "no_organisation" if doc has no organisation' do
    edition = create(:edition)
    assert_equal 'unknown_organisation', document_organisation_class(edition)
  end
end
