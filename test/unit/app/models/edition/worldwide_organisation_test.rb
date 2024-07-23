require "test_helper"

class Edition::WorldwideOrganisationTest < ActiveSupport::TestCase
  class EditionWithWorldwideOrganisations < Edition
    include ::Edition::WorldwideOrganisations
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

  def worldwide_organisations
    @worldwide_organisations ||= [
      create(:worldwide_organisation),
      create(:worldwide_organisation),
    ]
  end

  setup do
    @edition = EditionWithWorldwideOrganisations.create!(valid_edition_attributes.merge(worldwide_organisations:))
  end

  test "edition can be created with worldwide organisations" do
    assert_equal worldwide_organisations, @edition.worldwide_organisations
  end

  test "edition does not require worldwide organisations" do
    assert EditionWithWorldwideOrganisations.create!(valid_edition_attributes).valid?
  end

  test "copies the data sets over to a create draft" do
    published = create(:news_article_world_news_story, :published, worldwide_organisations:)
    assert_equal worldwide_organisations, published.create_draft(create(:user)).worldwide_organisations
  end

  test "returns published worldwide organisations" do
    published = create(:published_worldwide_organisation)
    draft = create(:draft_worldwide_organisation)

    edition = EditionWithWorldwideOrganisations.create!(valid_edition_attributes.merge(worldwide_organisations: [published, draft]))

    assert_equal [published], edition.published_worldwide_organisations
  end
end
