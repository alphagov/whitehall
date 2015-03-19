require 'test_helper'

class PoliticalContentIdentifierTest < ActiveSupport::TestCase
  test 'editions of a political format associated with one or more ministers is political' do
    edition = create(:news_article, role_appointments: [create(:ministerial_role_appointment)])

    assert PoliticalContentIdentifier.political?(edition)
  end

  test 'editions of a political format associated with a political orgs are political' do
    political_organisation = create(:organisation, :political)
    edition = create(:consultation, lead_organisations: [political_organisation])

    assert political?(edition)
  end

  test 'editions of a political format not associated with political orgs are not political' do
    non_political_organisation = create(:organisation, :non_political)
    edition = create(:consultation, lead_organisations: [non_political_organisation])

    refute political?(edition)
  end

  test 'editions of a non-political format associated with political orgs are not political' do
    political_organisation = create(:organisation, :political)
    edition = create(:detailed_guide, lead_organisations: [political_organisation])

    refute political?(edition)
  end

  test 'publications that are of a political sub-type associated with political orgs are political' do
    political_organisation = create(:organisation, :political)
    edition = create(:publication, :policy_paper, lead_organisations: [political_organisation])

    assert political?(edition)
  end

  test 'publications of a non-political sub-type not associated with political orgs are not political' do
    political_organisation = create(:organisation, :political)
    edition = create(:publication, :statistics, lead_organisations: [political_organisation])

    refute political?(edition)
  end

  test 'editions associated with a minister are political, even if not from a political organisation and not of a political format' do
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
