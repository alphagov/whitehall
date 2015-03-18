require 'test_helper'

class PoliticalContentIdentifierTest < ActiveSupport::TestCase
  test '#political?(edition) is true if content is tagged to a minister' do
    edition = create(:speech, role_appointment: create(:ministerial_role_appointment))

    assert PoliticalContentIdentifier.political?(edition)
  end

  test '#political?(edition) is true if content is tagged to one or more ministers' do
    edition = create(:news_article, role_appointments: [create(:ministerial_role_appointment)])

    assert PoliticalContentIdentifier.political?(edition)
  end

  test '#political?(edition) is true if content is from a political org and is a political format' do
    political_organisation = create(:organisation, :political)
    edition = create(:consultation, lead_organisations: [political_organisation])

    assert PoliticalContentIdentifier.political?(edition)
  end

  test '#political?(edition) is true if content is from a political org and is a political subformat' do
    political_organisation = create(:organisation, :political)
    edition = create(:publication, :policy_paper, lead_organisations: [political_organisation])

    assert PoliticalContentIdentifier.political?(edition)
  end

  test '#political?(edition) is false if content is from a political org but not a political format' do
    political_organisation = create(:organisation, :political)
    edition = create(:detailed_guide, lead_organisations: [political_organisation])

    refute PoliticalContentIdentifier.political?(edition)
  end

  test '#political?(edition) is false if content is from a political org but not a political subformat' do
    political_organisation = create(:organisation, :political)
    edition = create(:publication, :statistics, lead_organisations: [political_organisation])

    refute PoliticalContentIdentifier.political?(edition)
  end

  test '#political?(edition) is true if content is not from a political org, is a non-political Publication type, but is associated with a minister' do
    non_political_organisation = create(:organisation, :non_political)
    edition = create(:publication, :statistics,
      lead_organisations: [non_political_organisation],
      ministerial_roles: [create(:ministerial_role)]
    )

    assert PoliticalContentIdentifier.political?(edition)
  end

  test '#political?(edition) is false if content is a political format but not from a political org' do
    non_political_organisation = create(:organisation, :non_political)
    edition = create(:consultation, lead_organisations: [non_political_organisation])

    refute PoliticalContentIdentifier.political?(edition)
  end
end
