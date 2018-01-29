require 'test_helper'
class PublishingApi::WorldLocationNewsArticlePresenterTest < ActiveSupport::TestCase
  setup do
    create(:current_government)

    @world_location_news_article = create(
      :world_location_news_article,
      title: "World Location News Article title",
      summary: "World Location News Article summary"
    )

    @presented_world_location_news_article = PublishingApi::WorldLocationNewsArticlePresenter.new(@world_location_news_article)
    @presented_content = I18n.with_locale("de") { @presented_world_location_news_article.content }
  end

  test "it presents a valid world_location_news_article content item" do
    assert_valid_against_schema @presented_content, "world_location_news_article"
  end

  test "it delegates the content id" do
    assert_equal @world_location_news_article.content_id, @presented_world_location_news_article.content_id
  end

  test "it presents the title" do
    assert_equal "World Location News Article title", @presented_content[:title]
  end

  test "it presents the summary as the description" do
    assert_equal "World Location News Article summary", @presented_content[:description]
  end

  test "it presents the base_path" do
    assert_equal "/government/world-location-news/world-location-news-article-title.de", @presented_content[:base_path]
  end

  test "it presents updated_at if public_timestamp is nil" do
    assert_equal @world_location_news_article.updated_at, @presented_content[:public_updated_at]
  end

  test "it presents the publishing_app as whitehall" do
    assert_equal 'whitehall', @presented_content[:publishing_app]
  end

  test "it presents the rendering_app as government-frontend" do
    assert_equal 'government-frontend', @presented_content[:rendering_app]
  end

  test "it presents the schema_name as world_location_news_article" do
    assert_equal "world_location_news_article", @presented_content[:schema_name]
  end

  test "it presents the document type as world_location_news_article" do
    assert_equal "world_location_news_article", @presented_content[:document_type]
  end

  test "it presents the global process wide locale as the locale of the world_location_news_article" do
    assert_equal "de", @presented_content[:locale]
  end
end

class PublishingApi::WorldLocationNewsArticleWithPublicTimestampTest < ActiveSupport::TestCase
  setup do
    @expected_time = Time.zone.parse("10/01/2016")
    @world_location_news_article = create(
      :world_location_news_article
    )
    @world_location_news_article.public_timestamp = @expected_time
    @presented_world_location_news_article = PublishingApi::WorldLocationNewsArticlePresenter.new(@world_location_news_article)
  end

  test "it presents public_timestamp if it exists" do
    assert_equal @expected_time, @presented_world_location_news_article.content[:public_updated_at]
  end
end

class PublishingApi::DraftWorldLocationNewsArticlePresenter < ActiveSupport::TestCase
  test "it presents the world location news article's parent document created_at as first_public_at" do
    presented_notice = PublishingApi::WorldLocationNewsArticlePresenter.new(
      create(:draft_world_location_news_article) do |world_location_news_article|
        world_location_news_article.document.stubs(:created_at).returns(Date.new(2015, 4, 10))
      end
    )

    assert_equal(
      Date.new(2015, 4, 10),
      presented_notice.content[:details][:first_public_at]
    )
  end
end

class PublishingApi::WorldLocationNewsArticleBelongingToPublishedDocumentNoticePresenter < ActiveSupport::TestCase
  test "it presents the World Location News Article's first_published_at as first_public_at" do
    presented_notice = PublishingApi::WorldLocationNewsArticlePresenter.new(
      create(:published_world_location_news_article) do |world_location_news_article|
        world_location_news_article.stubs(:first_published_at).returns(Date.new(2015, 4, 10))
      end
    )

    assert_equal(
      Date.new(2015, 4, 10),
      presented_notice.content[:details][:first_public_at]
    )
  end
end

class PublishingApi::WorldLocationNewsArticlePresenterDetailsTest < ActiveSupport::TestCase
  setup do
    @expected_first_published_at = Time.new(2015, 12, 25)
    @world_location_news_article = create(
      :world_location_news_article,
      :published,
      body: "*Test string*",
      first_published_at: @expected_first_published_at
    )

    @presented_content = PublishingApi::WorldLocationNewsArticlePresenter.new(@world_location_news_article).content
    @presented_details = @presented_content[:details]
  end

  test "it presents first_public_at as details, first_public_at" do
    assert_equal @expected_first_published_at, @presented_details[:first_public_at]
  end

  test "it presents change_history" do
    change_history = [
      {
        "public_timestamp" => @expected_first_published_at,
        "note" => "change-note"
      }
    ]

    assert_equal change_history, @presented_details[:change_history]
  end
end

class PublishingApi::WorldLocationNewsArticlePresenterLinksTest < ActiveSupport::TestCase
  setup do
    @world_location_news_article = create(:world_location_news_article)
    presented_world_location_news_article = PublishingApi::WorldLocationNewsArticlePresenter.new(@world_location_news_article)
    @presented_links = presented_world_location_news_article.links
  end

  test "it presents the worldwide organisation content_ids as links, worldwide_organisations" do
    assert_equal(
      @world_location_news_article.worldwide_organisations.map(&:content_id),
      @presented_links[:worldwide_organisations]
    )
  end

  test "it presents the world location content_ids as links, world_locations" do
    assert_equal(
      @world_location_news_article.world_locations.map(&:content_id),
      @presented_links[:world_locations]
    )
  end

  test "it presents the topics(or specialist sectors as they used to be) content_ids as links, topics" do
    assert_equal(
      @world_location_news_article.specialist_sectors.map(&:content_id),
      @presented_links[:topics]
    )
  end

  test "it presents the primary_specialist_sector content_ids as links, parent" do
    assert_equal(
      @world_location_news_article.primary_specialist_sectors.map(&:content_id),
      @presented_links[:parent]
    )
  end
end

class PublishingApi::WorldLocationNewsArticlePresenterUpdateTypeTest < ActiveSupport::TestCase
  setup do
    @presented_world_location_news_article = PublishingApi::WorldLocationNewsArticlePresenter.new(
      create(:world_location_news_article, minor_change: false)
    )
  end

  test "if the update type is not supplied it presents based on the item" do
    assert_equal "major", @presented_world_location_news_article.update_type
  end
end

class PublishingApi::WorldLocationNewsArticlePresenterMinorUpdateTypeTest < ActiveSupport::TestCase
  setup do
    @presented_world_location_news_article = PublishingApi::WorldLocationNewsArticlePresenter.new(
      create(:world_location_news_article, minor_change: true)
    )
  end

  test "if the update type is not supplied it presents based on the item" do
    assert_equal "minor", @presented_world_location_news_article.update_type
  end
end

class PublishingApi::WorldLocationNewsArticlePresenterUpdateTypeArgumentTest < ActiveSupport::TestCase
  setup do
    @presented_world_location_news_article = PublishingApi::WorldLocationNewsArticlePresenter.new(
      create(:world_location_news_article, minor_change: true),
      update_type: "major"
    )
  end

  test "presents based on the supplied update type argument" do
    assert_equal "major", @presented_world_location_news_article.update_type
  end
end

class PublishingApi::WorldLocationNewsArticlePresenterCurrentGovernmentTest < ActiveSupport::TestCase
  setup do
    # Goverments are not explicitly associated with an Edition.
    # The Government is determined based on date of publication.
    create(
      :current_government,
      name: "The Current Government",
      slug: "the-current-government",
    )
    @presented_world_location_news_article = PublishingApi::WorldLocationNewsArticlePresenter.new(
      create(:world_location_news_article)
    )
  end

  test "presents a current government" do
    assert_equal(
      {
        "title": "The Current Government",
        "slug": "the-current-government",
        "current": true
      },
      @presented_world_location_news_article.content[:details][:government]
    )
  end
end

class PublishingApi::WorldLocationNewsArticlePresenterPreviousGovernmentTest < ActiveSupport::TestCase
  setup do
    # Goverments are not explicitly associated with an Edition.
    # The Government is determined based on date of publication.
    create(:current_government)
    previous_government = create(
      :previous_government,
      name: "A Previous Government",
      slug: "a-previous-government",
    )
    @presented_world_location_news_article = PublishingApi::WorldLocationNewsArticlePresenter.new(
      create(
        :world_location_news_article,
        first_published_at: previous_government.start_date + 1.day
      )
    )
  end

  test "presents a previous government" do
    assert_equal(
      {
        "title": "A Previous Government",
        "slug": "a-previous-government",
        "current": false
      },
      @presented_world_location_news_article.content[:details][:government]
    )
  end
end

class PublishingApi::WorldLocationNewsArticlePresenterPoliticalTest < ActiveSupport::TestCase
  setup do
    world_location_news_article = create(:world_location_news_article)
    world_location_news_article.stubs(:political?).returns(true)
    @presented_world_location_news_article = PublishingApi::WorldLocationNewsArticlePresenter.new(
      world_location_news_article
    )
  end

  test "presents political" do
    assert @presented_world_location_news_article.content[:details][:political]
  end
end

class PublishingApi::WorldLocationNewsArticleAccessLimitedTest < ActiveSupport::TestCase
  setup do
    create(:current_government)
    world_location_news_article = create(:world_location_news_article)

    PublishingApi::PayloadBuilder::AccessLimitation.expects(:for)
      .with(world_location_news_article)
      .returns(
        access_limited: { users: %w(abcdef12345) }
      )
    @presented_world_location_news_article = PublishingApi::WorldLocationNewsArticlePresenter.new(
      world_location_news_article
    )
  end

  test "include access limiting" do
    assert_equal %w(abcdef12345), @presented_world_location_news_article.content[:access_limited][:users]
  end

  test "is valid against content schemas" do
    assert_valid_against_schema @presented_world_location_news_article.content, "world_location_news_article"
  end
end

class PublishingApi::WorldLocationNewsArticleImageDetailsTest < ActiveSupport::TestCase
  setup do
    create(:current_government)
    @image = build(:image, alt_text: 'Image alt text', caption: 'Image caption')
    @world_location_news_article = create(:world_location_news_article, images: [@image])
    @presented_world_location_news_article = PublishingApi::WorldLocationNewsArticlePresenter.new(@world_location_news_article)
  end

  test "includes details of the world location news article image if present" do
    expected_hash = {
      url: @image.url(:s300),
      alt_text: @image.alt_text,
      caption: @image.caption
    }

    assert_valid_against_schema(@presented_world_location_news_article.content, 'world_location_news_article')
    assert_equal expected_hash, @presented_world_location_news_article.content[:details][:image]
  end
end

class PublishingApi::WorldLocationNewsArticlePlaceholderImageTest < ActiveSupport::TestCase
  setup do
    create(:current_government)
    @wlna = create(:world_location_news_article)
    @presented_wlna = PublishingApi::WorldLocationNewsArticlePresenter.new(@wlna)
  end

  test "includes a placeholder image when no image is presented" do
    expected_placeholder_image = {
      alt_text: "placeholder",
      caption: nil,
      url: Whitehall.public_asset_host + "/government/assets/placeholder.jpg"
    }

    assert_equal expected_placeholder_image, @presented_wlna.content[:details][:image]
  end
end
