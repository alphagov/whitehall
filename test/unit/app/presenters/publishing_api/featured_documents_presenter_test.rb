require "test_helper"

class PublishingApi::FeaturedDocumentsPresenterTest < ActiveSupport::TestCase
  include PublishingApi::FeaturedDocumentsPresenter

  test("determines ordered featured documents in different locales for editions") do
    case_study = create(:published_case_study)
    first_feature = build(:feature, document: case_study.document, ordering: 1)
    news_article = create(:published_news_article)
    second_feature = build(:feature, document: news_article.document, ordering: 2)
    featured_documents_display_limit = 5

    world_location = create(:world_location)

    locales = [
      { code: "en", suffix: "" },
      { code: "fr", suffix: ".fr" },
    ]

    locales.each do |locale|
      I18n.with_locale(locale[:code]) do
        create(:feature_list, locale: locale[:code], featurable: world_location.world_location_news, features: [second_feature, first_feature])

        expected_ordered_featured_documents = [
          { title: case_study.title,
            href: "/government/case-studies/case-study-title#{locale[:suffix]}",
            image: { url: first_feature.image.url,
                     alt_text: "" },
            summary: Whitehall::GovspeakRenderer.new.govspeak_to_html(case_study.summary),
            public_updated_at: case_study.public_timestamp,
            document_type: I18n.t("document.type.case_study.one") },
          { title: news_article.title,
            href: "/government/news/news-title#{locale[:suffix]}",
            image: { url: second_feature.image.url,
                     alt_text: "" },
            summary: Whitehall::GovspeakRenderer.new.govspeak_to_html(news_article.summary),
            public_updated_at: news_article.public_timestamp,
            document_type: I18n.t("document.type.press_release.one") },
        ]

        assert_equal expected_ordered_featured_documents, featured_documents(world_location.world_location_news, featured_documents_display_limit)
      end
    end
  end

  test("determines ordered featured documents in different locales for topical events") do
    topical_event = create(:topical_event, name: "topical_event_1", start_date: 1.year.ago.to_date)
    feature = build(:feature, document: nil, topical_event:, ordering: 1)
    featured_documents_display_limit = 5

    organisation = create(:organisation)

    locales = [
      { code: "en", suffix: "" },
      { code: "fr", suffix: ".fr" },
    ]

    locales.each do |locale|
      I18n.with_locale(locale[:code]) do
        create(:feature_list, locale: locale[:code], featurable: organisation, features: [feature])

        expected_ordered_featured_documents = [
          { title: topical_event.name,
            href: "/government/topical-events/topical_event_1#{locale[:suffix]}",
            image: { url: feature.image.url,
                     alt_text: feature.alt_text },
            summary: Whitehall::GovspeakRenderer.new.govspeak_to_html(topical_event.summary),
            public_updated_at: topical_event.start_date,
            document_type: nil },
        ]

        assert_equal expected_ordered_featured_documents, featured_documents(organisation, featured_documents_display_limit)
      end
    end
  end

  test("determines ordered featured documents in different locales for offsite links") do
    offsite_link = create(:offsite_link, date: 1.year.ago.to_date)
    feature = build(:feature, document: nil, offsite_link:, ordering: 1)
    featured_documents_display_limit = 5

    organisation = create(:organisation)

    locales = %i[en fr]

    locales.each do |locale|
      I18n.with_locale(locale) do
        create(:feature_list, locale:, featurable: organisation, features: [feature])

        expected_ordered_featured_documents = [
          { title: offsite_link.title,
            href: offsite_link.url,
            image: { url: feature.image.url,
                     alt_text: feature.alt_text },
            summary: Whitehall::GovspeakRenderer.new.govspeak_to_html(offsite_link.summary),
            public_updated_at: offsite_link.date,
            document_type: offsite_link.display_type },
        ]

        assert_equal expected_ordered_featured_documents, featured_documents(organisation, featured_documents_display_limit)
      end
    end
  end

  test("caps number of documents at limit when it exceeds this") do
    first_feature = build(:feature, document: create(:published_case_study).document, ordering: 1)
    second_feature = build(:feature, document: create(:published_news_article).document, ordering: 2)

    world_location = create(:world_location)

    create(:feature_list, locale: :en, featurable: world_location.world_location_news, features: [second_feature, first_feature])

    document_limit = 1
    presented_locations = featured_documents(world_location.world_location_news, document_limit)

    assert_equal [create(:published_case_study).title], (presented_locations.map { |presented_location| presented_location[:title] })
  end
end
