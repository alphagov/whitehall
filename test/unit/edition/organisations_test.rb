require "test_helper"

class Edition::OrganisationsTest < ActiveSupport::TestCase
  test "new edition of document featured in organisation should remain featured in that organisation" do
    news_article = create(:published_news_article)
    organisation = create(:organisation)
    create(:edition_organisation, featured: true, edition: news_article, organisation: organisation)

    new_edition = news_article.create_draft(create(:policy_writer))
    new_edition.publish_as(create(:departmental_editor), force: true)

    edition_organisation = new_edition.edition_organisations.first
    assert edition_organisation.featured?
  end

  test "new edition of document not featured in organisation should remain unfeatured in that organisation" do
    news_article = create(:published_news_article)
    organisation = create(:organisation)
    create(:edition_organisation, featured: false, edition: news_article, organisation: organisation)

    new_edition = news_article.create_draft(create(:policy_writer))
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
end
