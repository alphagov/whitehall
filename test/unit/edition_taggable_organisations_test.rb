require "test_helper"

class EditionTaggableOrganisationTestForEducationOrganisations < ActiveSupport::TestCase
  def setup
    @lead_org = create(:organisation)
    orgs_in_tagging_beta = {
      "education_related" => [@lead_org.content_id],
      "worldwide_related" => []
    }
    Whitehall.stubs(:organisations_in_tagging_beta).returns(orgs_in_tagging_beta)
  end

  # method will return `true` for all other edition types, we choose NewsArticle as example
  test '#can_be_tagged_to_taxonomy? is true for NewsArticle' do
    edition = create(:news_article, organisations: [@lead_org])

    assert edition.can_be_tagged_to_taxonomy?
  end

  test '#must_be_tagged_to_taxonomy? is true for NewsArticle' do
    edition = create(:news_article, organisations: [@lead_org])

    assert edition.must_be_tagged_to_taxonomy?
  end
end

class EditionTaggableOrganisationTestForWorldOrganisations < ActiveSupport::TestCase
  def setup
    @lead_org = create(:organisation)
    orgs_in_tagging_beta = {
      "education_related" => [],
      "worldwide_related" => [@lead_org.content_id]
    }
    Whitehall.stubs(:organisations_in_tagging_beta).returns(orgs_in_tagging_beta)
  end

  # Users are not required to tag World taggable editions in order to publish
  test '#must_be_tagged_to_taxonomy? is false for DetailedGuide' do
    edition = create(:detailed_guide, organisations: [@lead_org])

    refute edition.must_be_tagged_to_taxonomy?
  end

  test '#can_be_tagged_to_taxonomy? is true for Publication Guidance' do
    edition = create(:publication,
                     :draft,
                     access_limited: false,
                     publication_type_id: PublicationType::Guidance.id,
                     organisations: [@lead_org])

    assert edition.can_be_tagged_to_taxonomy?
  end

  test '#can_be_tagged_to_taxonomy? is true for Publication Form' do
    edition = create(:publication,
                     :draft,
                     access_limited: false,
                     publication_type_id: PublicationType::Form.id,
                     organisations: [@lead_org])

    assert edition.can_be_tagged_to_taxonomy?
  end

  test '#can_be_tagged_to_taxonomy? is false for other Publication types' do
    other_publication_types = PublicationType.all.reject do |publication_type|
      [PublicationType::Guidance, PublicationType::Form].include?(publication_type) ||
        publication_type.prevalence == :migration
    end

    other_publication_types.each_with_index do |publication_type, index|
      edition = create(:publication,
                       :draft,
                       title: "Title #{index}",
                       access_limited: false,
                       publication_type_id: publication_type.id,
                       organisations: [@lead_org])

      refute edition.can_be_tagged_to_taxonomy?
    end
  end

  test '#can_be_tagged_to_taxonomy? is true for DetailedGuide' do
    edition = create(:detailed_guide, organisations: [@lead_org])

    assert edition.can_be_tagged_to_taxonomy?
  end

  # method will return `false` for all other edition types, we choose NewsArticle as example
  test '#can_be_tagged_to_taxonomy? is false for NewsArticle' do
    edition = create(:news_article, organisations: [@lead_org])

    refute edition.can_be_tagged_to_taxonomy?
  end
end
