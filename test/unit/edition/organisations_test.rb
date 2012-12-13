require "test_helper"

class Edition::OrganisationsTest < ActiveSupport::TestCase
  test "new edition of document featured in organisation should remain featured in that organisation with image and alt text" do
    featured_image = create(:edition_organisation_image_data)
    organisation = create(:organisation)
    news_article = create(:published_news_article, organisations: [organisation])
    association = news_article.association_with_organisation(organisation)
    association.image = featured_image
    association.alt_text = "alt-text"
    association.featured = true
    association.save!

    new_edition = news_article.create_draft(create(:policy_writer))
    new_edition.change_note = 'change-note'
    new_edition.publish_as(create(:departmental_editor), force: true)

    edition_organisation = new_edition.edition_organisations.first
    assert edition_organisation.featured?
    assert_equal featured_image, edition_organisation.image
    assert_equal "alt-text", edition_organisation.alt_text
  end

  test "new edition of document not featured in organisation should remain unfeatured in that organisation" do
    news_article = create(:published_news_article)
    organisation = create(:organisation)
    create(:edition_organisation, featured: false, edition: news_article, organisation: organisation)

    new_edition = news_article.create_draft(create(:policy_writer))
    new_edition.change_note = 'change-note'
    new_edition.publish_as(create(:departmental_editor), force: true)

    edition_organisation = new_edition.edition_organisations.first
    refute edition_organisation.featured?
  end

  test "#destroy removes relationship with organisation" do
    edition = create(:draft_policy, organisations: [create(:organisation)])
    relation = edition.edition_organisations.first
    edition.destroy
    refute EditionOrganisation.find_by_id(relation.id)
  end

  test "in_organisation should return editions with all associated organisations loaded when includes has also been invoked" do
    dfid = create(:organisation)
    dwp = create(:organisation)
    create(:draft_detailed_guide, title: "find-me", organisations: [dfid, dwp])
    create(:draft_detailed_guide, title: "ignore-me", organisations: [dwp])

    assert 3 > count_queries {
      editions = DetailedGuide.includes(:organisations).in_organisation([dfid])
      assert_equal 1, editions.length
      assert_equal "find-me", editions[0].title
      assert_equal 0, count_queries {
        assert_same_elements [dfid, dwp], editions[0].organisations
      }, "loading organisations should not contact the database"
    }, "organisations association wasn't eager-loaded"
  end

  test "new edition of document will retain lead and supporting organisations and their orderings" do
    organisation_1 = create(:organisation)
    organisation_2 = create(:organisation)
    organisation_3 = create(:organisation)
    news_article = create(:published_news_article, lead_organisations: [organisation_3, organisation_1], supporting_organisations: [organisation_2])

    new_edition = news_article.create_draft(create(:policy_writer))
    new_edition.change_note = 'change-note'
    new_edition.publish_as(create(:departmental_editor), force: true)

    lead_edition_organisations = new_edition.lead_edition_organisations
    assert_equal 2, lead_edition_organisations.size
    assert_equal organisation_3, lead_edition_organisations[0].organisation
    assert_equal organisation_1, lead_edition_organisations[1].organisation

    supporting_edition_organisations = new_edition.supporting_edition_organisations
    assert_equal 1, supporting_edition_organisations.size
    assert_equal organisation_2, supporting_edition_organisations[0].organisation
  end

end
