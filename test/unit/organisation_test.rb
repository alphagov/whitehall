require 'test_helper'

class OrganisationTest < ActiveSupport::TestCase
  test 'should be valid when built from the factory' do
    organisation = build(:organisation)
    assert organisation.valid?
  end

  test 'should be invalid without a name' do
    organisation = build(:organisation, name: nil)
    refute organisation.valid?
  end

  test 'should be invalid with a duplicate name' do
    existing_organisation = create(:organisation)
    new_organisation = build(:organisation, name: existing_organisation.name)
    refute new_organisation.valid?
  end

  test "should return a list of published policies" do
    organisation_1 = create(:organisation)
    organisation_2 = create(:organisation)
    draft_policy = create(:draft_policy, organisations: [organisation_1])
    published_policy = create(:published_policy, organisations: [organisation_1])
    published_publication = create(:published_publication, organisations: [organisation_1])
    create(:published_policy, organisations: [organisation_2])

    assert_equal [published_policy], organisation_1.reload.published_policies
  end

  test "should return a list of published publications" do
    organisation_1 = create(:organisation)
    organisation_2 = create(:organisation)
    draft_publication = create(:draft_publication, organisations: [organisation_1])
    published_publication = create(:published_publication, organisations: [organisation_1])
    published_policy = create(:published_policy, organisations: [organisation_1])
    create(:published_publication, organisations: [organisation_2])

    assert_equal [published_publication], organisation_1.reload.published_publications
  end
end