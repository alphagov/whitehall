require "test_helper"

class Edition::OrganisationsTest < ActiveSupport::TestCase
  test "#destroy removes relationship with organisation" do
    edition = create(:draft_publication, organisations: [create(:organisation)])
    relation = edition.edition_organisations.first
    edition.destroy
    assert_not EditionOrganisation.exists?(relation.id)
  end

  test "new edition of document will retain lead and supporting organisations and their orderings" do
    organisation_1 = create(:organisation)
    organisation_2 = create(:organisation)
    organisation_3 = create(:organisation)
    news_article = create(:published_news_article, lead_organisations: [organisation_3, organisation_1], supporting_organisations: [organisation_2])

    new_edition = news_article.create_draft(create(:writer))
    new_edition.change_note = 'change-note'
    force_publish(new_edition)

    lead_edition_organisations = new_edition.lead_edition_organisations
    assert_equal 2, lead_edition_organisations.size
    assert_equal organisation_3, lead_edition_organisations[0].organisation
    assert_equal organisation_1, lead_edition_organisations[1].organisation

    supporting_edition_organisations = new_edition.supporting_edition_organisations
    assert_equal 1, supporting_edition_organisations.size
    assert_equal organisation_2, supporting_edition_organisations[0].organisation
  end

  test 'reducing lead organisations from 2 to 1 (keeping the second) is ok' do
    organisation_1 = create(:organisation)
    organisation_2 = create(:organisation)
    edition = create(:publication, create_default_organisation: false,
                               lead_organisations: [organisation_1, organisation_2],
                               supporting_organisations: [])
    edition.lead_organisations = [organisation_2]
    assert_nothing_raised do
      edition.save!
    end
  end

  test '#sorted_organisations returns organisations in alphabetical order' do
    organisation_1 = create(:organisation, name: 'Ministry of Jazz')
    organisation_2 = create(:organisation, name: 'Free Jazz Foundation')
    organisation_3 = create(:organisation, name: 'Jazz Bizniz')
    edition = create(:published_news_article, lead_organisations: [organisation_3, organisation_1], supporting_organisations: [organisation_2])

    assert_equal [organisation_2, organisation_3, organisation_1], edition.sorted_organisations
  end

  test '#search_index should include organisations' do
    organisation_1 = create(:organisation, name: 'Ministry of Jazz')
    organisation_2 = create(:organisation, name: 'Free Jazz Foundation')
    edition = create(:published_news_article, organisations: [organisation_1, organisation_2])

    assert_equal %w[ministry-of-jazz free-jazz-foundation], edition.search_index["organisations"]
  end

  test '#importance_ordered_organisations' do
    first_lead_org = create(:organisation)
    second_lead_org = create(:organisation)
    supporting_org = create(:organisation)
    edition = create(:publication, lead_organisations: [first_lead_org, second_lead_org], supporting_organisations: [supporting_org])

    assert_equal [first_lead_org, second_lead_org, supporting_org], edition.importance_ordered_organisations
  end
end
