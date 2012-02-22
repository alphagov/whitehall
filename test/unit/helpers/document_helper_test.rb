require 'test_helper'

class DocumentHelperTest < ActionView::TestCase
  test "#document_organisation_class returns the slug of the organisation of the first document" do
    organisations = [create(:organisation), create(:organisation)]
    document = create(:document, organisations: organisations)
    assert_equal organisations.first.slug, document_organisation_class(document)
  end

  test "#document_organisation_class returns the slug of the root organisation of the first document" do
    parent_org = create(:ministerial_department)
    child_org = create(:organisation, parent_organisations: [parent_org])
    document = create(:document, organisations: [child_org])
    assert_equal parent_org.slug, document_organisation_class(document)
  end

  test '#document_organisation_class returns "no_organisation" if doc has no organisation' do
    document = create(:document)
    assert_equal 'unknown_organisation', document_organisation_class(document)
  end
end
