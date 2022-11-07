require "test_helper"

class PublishingApi::WorldLocationNewsPresenterTest < ActiveSupport::TestCase
  include PublishingApi::FeaturedDocumentsPresenter

  def present(...)
    PublishingApi::WorldLocationNewsPresenter.new(...)
  end

  setup do
    @world_location_news = build(:world_location_news, title: "Aardistan and the Uk", mission_statement: "This is a great mission", translated_into: :fr)
    @world_location = create(:world_location, name: "Aardistan", world_location_news: @world_location_news, translated_into: :fr)
  end

  def setup_feature_list
    case_study = create(:published_case_study)
    news_article = create(:published_news_article)
    create(:feature_list, featurable: @world_location_news, features:
      [
        build(:feature, document: news_article.document, ordering: 2),
        build(:feature, document: case_study.document, ordering: 1),
      ])
  end

  test "presents an item for publishing api" do
    newer_link = create(:featured_link, linkable: @world_location_news, title: "2 days ago", created_at: 2.days.ago)
    older_link = create(:featured_link, linkable: @world_location_news, title: "12 days ago", created_at: 12.days.ago)
    setup_feature_list

    expected = {
      title: "Aardistan and the Uk",
      locale: "en",
      publishing_app: "whitehall",
      redirects: [],
      description: "Updates, news and events from the UK government in Aardistan",
      details: {
        ordered_featured_links: [
          {
            title: older_link.title,
            href: older_link.url,
          },
          {
            title: newer_link.title,
            href: newer_link.url,
          },
        ],
        mission_statement: "This is a great mission",
        ordered_featured_documents: featured_documents(@world_location_news, WorldLocationNews::FEATURED_DOCUMENTS_DISPLAY_LIMIT),
        world_location_news_type: "world_location",
      },
      document_type: "world_location_news",
      public_updated_at: @world_location_news.updated_at,
      rendering_app: "collections",
      schema_name: "world_location_news",
      base_path: "/world/aardistan/news",
      routes: [{ path: "/world/aardistan/news", type: "exact" }],
      analytics_identifier: "WL#{@world_location.id}",
      update_type: "major",
    }

    presented_content = present(@world_location_news).content

    assert_equal expected, presented_content

    assert_valid_against_publisher_schema(presented_content, "world_location_news")
  end

  test "caps number of featured links at 5" do
    6.times do
      create(:featured_link, linkable: @world_location_news)
    end

    assert_equal 5, present(@world_location_news).content.dig(:details, :ordered_featured_links).size
  end

  test "caps number of featured documents at 5" do
    features = (1..6).to_a.map do |i|
      created_case_study = create(:published_case_study, title: "case-study-#{i}")
      build(:feature, document: created_case_study.document, ordering: i)
    end

    create(:feature_list, featurable: @world_location_news, features:)

    assert_equal 5, present(@world_location_news).content.dig(:details, :ordered_featured_documents).size
  end

  test "presents mission statement as an empty string when it is nil" do
    world_location_news_without_mission_statement = build(:world_location_news, mission_statement: nil)
    create(:world_location, world_location_news: world_location_news_without_mission_statement)

    presented_content = present(world_location_news_without_mission_statement).content

    assert_equal "", presented_content.dig(:details, :mission_statement)
  end

  test "it builds localised base paths correctly" do
    I18n.with_locale(:fr) do
      presented_item = present(@world_location_news)
      base_path = presented_item.content[:base_path]

      assert_equal "/world/aardistan/news.fr", base_path
    end
  end

  test "it does not include contact details for world locations" do
    world_location_news = build(:world_location_news)
    create(:world_location, :with_worldwide_organisations, world_location_news:)

    presented_links = present(world_location_news).links

    assert_equal [], presented_links[:ordered_contacts]
  end

  test "it does not include contact details for international delegation where location has no main office" do
    world_location_news = build(:world_location_news)
    create(:international_delegation, :with_worldwide_organisations, world_location_news:)

    presented_links = present(world_location_news).links

    assert_equal [], presented_links[:ordered_contacts]
  end

  test "it includes contact details for international delegation" do
    world_location_news = build(:world_location_news)
    world_location = create(:international_delegation, :with_worldwide_organisations, world_location_news:)
    create(:worldwide_office, worldwide_organisation: world_location.worldwide_organisations.first)

    presented_links = present(world_location_news).links

    assert_equal world_location_news.world_location.worldwide_organisations.map(&:main_office).map(&:contact).flatten.pluck(:content_id), presented_links[:ordered_contacts]
  end

  test "it does not include links to sponsoring organisations for world locations" do
    world_location_news = build(:world_location_news)
    create(:world_location, :with_worldwide_organisations, world_location_news:)

    presented_links = present(world_location_news).links

    assert_equal [], presented_links[:organisations]
  end

  test "it includes a link to sponsoring organisations for international delegation" do
    world_location_news = build(:world_location_news)
    create(:international_delegation, :with_worldwide_organisations, world_location_news:)

    presented_links = present(world_location_news).links

    assert_equal world_location_news.world_location.worldwide_organisations.map(&:sponsoring_organisations).flatten.pluck(:content_id), presented_links[:organisations]
  end

  test "it does not include links to worldwide organisations for world locations" do
    world_location_news = build(:world_location_news)
    create(:world_location, :with_worldwide_organisations, world_location_news:)

    presented_links = present(world_location_news).links

    assert_equal [], presented_links[:worldwide_organisations]
  end

  test "it includes a link to worldwide organisations for international delegation" do
    world_location_news = build(:world_location_news)
    world_location = create(:international_delegation, :with_worldwide_organisations, world_location_news:)
    create(:about_corporate_information_page, organisation: nil, worldwide_organisation: world_location.worldwide_organisations.first)

    presented_links = present(world_location_news).links

    assert_equal world_location.worldwide_organisations.map(&:content_id), presented_links[:worldwide_organisations]
  end
end
