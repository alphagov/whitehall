require 'test_helper'

class PoliticalContentIdentifierTest < ActiveSupport::TestCase
  test 'fatality notices are never political, even when associated with a minister' do
    fatality_notice = create(:fatality_notice,
      role_appointments: [create(:ministerial_role_appointment)])

    refute political?(fatality_notice)
  end

  test 'statistics publications are never political, even when associated with a minister' do
    statistics_publication = create(:publication, :statistics,
      role_appointments: [create(:ministerial_role_appointment)])

    refute political?(statistics_publication)
  end

  test 'world location news articles are always political' do
    world_location_news_article = create(:world_location_news_article)

    assert political?(world_location_news_article)
  end

  test 'world-news-story news articles are always political' do
    world_news_story = create(:news_article_world_news_story)

    assert political?(world_news_story)
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
    edition = create(:publication, :guidance, lead_organisations: [political_organisation])

    refute political?(edition)
  end

  test 'publications of a non-political sub-type associated with ministers are political' do
    political_organisation = create(:organisation, :political)
    edition = create(:publication, publication_type_id: PublicationType::Correspondence.id, role_appointments: [create(:ministerial_role_appointment)])

    assert political?(edition)
  end

  test 'political formats associated with ministers are political' do
    edition = create(:news_article, role_appointments: [create(:ministerial_role_appointment)])

    assert political?(edition)
  end

private

  def political?(edition)
    PoliticalContentIdentifier.political?(edition)
  end
end
