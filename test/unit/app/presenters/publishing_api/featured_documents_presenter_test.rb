require "test_helper"

class Presenters::PublishingApi::FeaturedDocumentsHelperTest < ActiveSupport::TestCase
  include Presenters::PublishingApi::FeaturedDocumentsHelper
  include GovspeakHelper

  test("determines ordered featured documents in different locales for editions") do
    fatality_notice = create(:published_fatality_notice)
    first_feature = build(:feature, document: fatality_notice.document, ordering: 1)
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", { "title" => "Featured standard edition", "settings" => { "base_path_prefix" => "/government/test" } }))
    standard_edition = create(:published_standard_edition, title: "Standard Edition Title")
    second_feature = build(:feature, document: standard_edition.document, ordering: 2)
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
          { title: fatality_notice.title,
            href: "/government/fatalities/fatality-title#{locale[:suffix]}",
            image: { url: "#{Plek.asset_root}/media/asset_manager_id_original/minister-of-funk.960x640.jpg",
                     medium_resolution_url: "#{Plek.asset_root}/media/asset_manager_id_s465/s465_minister-of-funk.960x640.jpg",
                     high_resolution_url: "#{Plek.asset_root}/media/asset_manager_id_s712/s712_minister-of-funk.960x640.jpg",
                     alt_text: "" },
            summary: govspeak_to_html(fatality_notice.summary),
            public_updated_at: fatality_notice.public_timestamp,
            document_type: I18n.t("document.type.fatality_notice.one") },
          { title: standard_edition.title,
            href: "/government/test/standard-edition-title#{locale[:suffix]}",
            image: { url: "#{Plek.asset_root}/media/asset_manager_id_original/minister-of-funk.960x640.jpg",
                     medium_resolution_url: "#{Plek.asset_root}/media/asset_manager_id_s465/s465_minister-of-funk.960x640.jpg",
                     high_resolution_url: "#{Plek.asset_root}/media/asset_manager_id_s712/s712_minister-of-funk.960x640.jpg",
                     alt_text: "" },
            summary: govspeak_to_html(standard_edition.summary),
            public_updated_at: standard_edition.public_timestamp,
            document_type: "Featured standard edition" },
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
            image: { url: "#{Plek.asset_root}/media/asset_manager_id_original/minister-of-funk.960x640.jpg",
                     medium_resolution_url: "#{Plek.asset_root}/media/asset_manager_id_s465/s465_minister-of-funk.960x640.jpg",
                     high_resolution_url: "#{Plek.asset_root}/media/asset_manager_id_s712/s712_minister-of-funk.960x640.jpg",
                     alt_text: "" },
            summary: govspeak_to_html(topical_event.summary),
            public_updated_at: topical_event.start_date,
            document_type: nil },
        ]

        assert_equal expected_ordered_featured_documents, featured_documents(organisation, featured_documents_display_limit)
      end
    end
  end

  test("determines ordered featured documents in different locales for offsite links") do
    organisation = create(:organisation)
    offsite_link = create(:offsite_link, organisations: [organisation], date: 1.year.ago.to_date)
    feature = build(:feature, document: nil, offsite_link:, ordering: 1)
    featured_documents_display_limit = 5

    locales = %i[en fr]

    locales.each do |locale|
      I18n.with_locale(locale) do
        create(:feature_list, locale:, featurable: organisation, features: [feature])

        expected_ordered_featured_documents = [
          { title: offsite_link.title,
            href: offsite_link.url,
            image: { url: "#{Plek.asset_root}/media/asset_manager_id_original/minister-of-funk.960x640.jpg",
                     medium_resolution_url: "#{Plek.asset_root}/media/asset_manager_id_s465/s465_minister-of-funk.960x640.jpg",
                     high_resolution_url: "#{Plek.asset_root}/media/asset_manager_id_s712/s712_minister-of-funk.960x640.jpg",
                     alt_text: "" },
            summary: govspeak_to_html(offsite_link.summary),
            public_updated_at: offsite_link.date,
            document_type: offsite_link.display_type },
        ]

        assert_equal expected_ordered_featured_documents, featured_documents(organisation, featured_documents_display_limit)
      end
    end
  end

  test("caps number of documents at limit when it exceeds this") do
    first_feature = build(:feature, document: create(:published_fatality_notice).document, ordering: 1)
    second_feature = build(:feature, document: create(:published_publication).document, ordering: 2)

    world_location = create(:world_location)

    create(:feature_list, locale: :en, featurable: world_location.world_location_news, features: [second_feature, first_feature])

    document_limit = 1
    presented_locations = featured_documents(world_location.world_location_news, document_limit)

    assert_equal([create(:published_fatality_notice).title], presented_locations.map { |presented_location| presented_location[:title] })
  end

  test("filters out featured documents if feature image assets are missing") do
    fatality_notice = create(:published_fatality_notice)
    first_feature = build(:feature, document: fatality_notice.document, ordering: 1)
    standard_edition = create(:published_fatality_notice)
    second_feature = build(:feature, document: standard_edition.document, ordering: 2)
    second_feature.image.assets = []
    featured_documents_display_limit = 5

    world_location = create(:world_location)

    create(:feature_list, featurable: world_location.world_location_news, features: [second_feature, first_feature])

    expected_ordered_featured_documents = [
      {
        title: fatality_notice.title,
        href: "/government/fatalities/fatality-title",
        image: { url: "#{Plek.asset_root}/media/asset_manager_id_original/minister-of-funk.960x640.jpg",
                 medium_resolution_url: "#{Plek.asset_root}/media/asset_manager_id_s465/s465_minister-of-funk.960x640.jpg",
                 high_resolution_url: "#{Plek.asset_root}/media/asset_manager_id_s712/s712_minister-of-funk.960x640.jpg",
                 alt_text: "" },
        summary: govspeak_to_html(fatality_notice.summary),
        public_updated_at: fatality_notice.public_timestamp,
        document_type: I18n.t("document.type.fatality_notice.one"),
      },
    ]

    assert_equal expected_ordered_featured_documents, featured_documents(world_location.world_location_news, featured_documents_display_limit)
  end
end
