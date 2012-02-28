require "test_helper"

class Document::OrganisationsTest < ActiveSupport::TestCase
  test "new edition of document featured in organisation should remain featured in that organisation" do
    news_article = create(:published_news_article)
    organisation = create(:organisation)
    create(:document_organisation, featured: true, document: news_article, organisation: organisation)

    new_edition = news_article.create_draft(create(:policy_writer))
    new_edition.publish_as(create(:departmental_editor), force: true)

    document_organisation = new_edition.document_organisations.first
    assert document_organisation.featured?
  end

  test "new edition of document not featured in organisation should remain unfeatured in that organisation" do
    news_article = create(:published_news_article)
    organisation = create(:organisation)
    create(:document_organisation, featured: false, document: news_article, organisation: organisation)

    new_edition = news_article.create_draft(create(:policy_writer))
    new_edition.publish_as(create(:departmental_editor), force: true)

    document_organisation = new_edition.document_organisations.first
    refute document_organisation.featured?
  end

  test "#destroy removes relationship with organisation" do
    document = create(:draft_policy, organisations: [create(:organisation)])
    relation = document.document_organisations.first
    document.destroy
    refute DocumentOrganisation.find_by_id(relation.id)
  end
end
