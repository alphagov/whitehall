require "test_helper"

class Edition::OrganisationsTest < ActiveSupport::TestCase
  test "new edition of document featured in organisation should remain featured in that organisation with image and alt text" do
    featured_image = create(:edition_organisation_image_data)
    news_article = create(:published_news_article)
    organisation = create(:organisation)
    create(:featured_edition_organisation, edition: news_article, organisation: organisation, image: featured_image, alt_text: "alt-text")

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
    create(:draft_specialist_guide, title: "find-me", organisations: [dfid, dwp])
    create(:draft_specialist_guide, title: "ignore-me", organisations: [dwp])

    assert 3 > count_queries {
      editions = SpecialistGuide.includes(:organisations).in_organisation([dfid])
      assert_equal 1, editions.length
      assert_equal "find-me", editions[0].title
      assert_equal 0, count_queries {
        assert_same_elements [dfid, dwp], editions[0].organisations
      }, "loading organisations should not contact the database"
    }, "organisations association wasn't eager-loaded"
  end
end
