require 'test_helper'

class PoliticalContentIdentifierTest < ActiveSupport::TestCase
  test 'political formats associated with ministerial role appointments are political' do
    edition = create(:news_article, role_appointments: [create(:ministerial_role_appointment)])

    assert political?(edition)
  end

  test 'political formats associated with a political orgs are political' do
    political_organisation = create(:organisation, :political)
    edition = create(:consultation, lead_organisations: [political_organisation])

    assert political?(edition)
  end

  test 'political formats not associated with political orgs are not political' do
    non_political_organisation = create(:organisation, :non_political)
    edition = create(:consultation, lead_organisations: [non_political_organisation])

    refute political?(edition)
  end

  test 'non-political formats associated with political orgs are not political' do
    political_organisation = create(:organisation, :political)
    edition = create(:detailed_guide, lead_organisations: [political_organisation])

    refute political?(edition)
  end

  test 'publications of a political sub-type associated with political orgs are political' do
    political_organisation = create(:organisation, :political)
    edition = create(:publication, :policy_paper, lead_organisations: [political_organisation])

    assert political?(edition)
  end

  test 'publications of a non-political sub-type associated with political orgs are not political' do
    political_organisation = create(:organisation, :political)
    edition = create(:publication, :statistics, lead_organisations: [political_organisation])

    refute political?(edition)
  end

  test 'formats associated with a minister are always political, regardless of format and any other associations' do
    non_political_organisation = create(:organisation, :non_political)
    edition = create(:publication, :statistics,
      lead_organisations: [non_political_organisation],
      ministerial_roles: [create(:ministerial_role)]
    )

    assert political?(edition)
  end

private

  def political?(edition)
    PoliticalContentIdentifier.political?(edition)
  end
end
