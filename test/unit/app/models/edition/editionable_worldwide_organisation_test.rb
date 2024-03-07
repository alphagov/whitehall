require "test_helper"

class Edition::EditionableWorldwideOrganisationTest < ActiveSupport::TestCase
  class EditionWithWorldwideOrganisations < Edition
    include ::Edition::EditionableWorldwideOrganisations
  end

  include ActionDispatch::TestProcess

  def valid_edition_attributes
    {
      title: "edition-title",
      body: "edition-body",
      summary: "edition-summary",
      creator: create(:user),
      previously_published: false,
    }
  end

  def editionable_worldwide_organisations
    @editionable_worldwide_organisations ||= [
      create(:editionable_worldwide_organisation),
      create(:editionable_worldwide_organisation),
    ]
  end

  setup do
    @edition = EditionWithWorldwideOrganisations.create!(valid_edition_attributes.merge(editionable_worldwide_organisations:))
  end

  test "edition can be created with editionable worldwide organisations" do
    assert_equal editionable_worldwide_organisations, @edition.editionable_worldwide_organisations
  end

  test "edition does not require editionable worldwide organisations" do
    assert EditionWithWorldwideOrganisations.create!(valid_edition_attributes).valid?
  end

  test "copies the data sets over to a create draft" do
    published = create(:news_article_world_news_story, :published, editionable_worldwide_organisations:)
    assert_equal editionable_worldwide_organisations, published.create_draft(create(:user)).editionable_worldwide_organisations
  end

  test "returns published editionable worldwide organisations" do
    published = create(:published_editionable_worldwide_organisation)
    draft = create(:draft_editionable_worldwide_organisation)

    edition = EditionWithWorldwideOrganisations.create!(valid_edition_attributes.merge(editionable_worldwide_organisations: [published, draft]))

    assert_equal [published], edition.published_editionable_worldwide_organisations
  end
end
