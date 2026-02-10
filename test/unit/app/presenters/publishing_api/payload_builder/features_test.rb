require "test_helper"

module PublishingApi
  module PayloadBuilder
    class FeaturesTest < ActiveSupport::TestCase
      include GovspeakHelper
      test "it returns the expected featured documents" do
        ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
          "settings" => {
            "features_enabled" => true,
          },
        }))
        featuring_edition = create(:published_standard_edition)
        featured_edition_1 = create(:published_consultation)
        featured_edition_2 = create(:published_publication)
        featured_edition_3 = create(:published_edition)

        features = [
          create(:feature, document: featured_edition_1.document),
          create(:feature, document: featured_edition_2.document),
          create(:feature, document: featured_edition_3.document),
        ]

        create(:feature_list, featurable: featuring_edition, features:)
        result = Features.for(featuring_edition)

        expected_result = {
          ordered_featured_documents: [
            {
              title: featured_edition_1.title,
              href: featured_edition_1.base_path,
              image: { url: "#{Plek.asset_root}/media/asset_manager_id_original/minister-of-funk.960x640.jpg",
                       medium_resolution_url: "#{Plek.asset_root}/media/asset_manager_id_s465/s465_minister-of-funk.960x640.jpg",
                       high_resolution_url: "#{Plek.asset_root}/media/asset_manager_id_s712/s712_minister-of-funk.960x640.jpg",
                       alt_text: "" },
              summary: govspeak_to_html(featured_edition_1.summary),
              public_updated_at: featured_edition_1.public_timestamp,
              document_type: "Open consultation",

            },
            {
              title: featured_edition_2.title,
              href: featured_edition_2.base_path,
              image: { url: "#{Plek.asset_root}/media/asset_manager_id_original/minister-of-funk.960x640.jpg",
                       medium_resolution_url: "#{Plek.asset_root}/media/asset_manager_id_s465/s465_minister-of-funk.960x640.jpg",
                       high_resolution_url: "#{Plek.asset_root}/media/asset_manager_id_s712/s712_minister-of-funk.960x640.jpg",
                       alt_text: "" },
              summary: govspeak_to_html(featured_edition_2.summary),
              public_updated_at: featured_edition_2.public_timestamp,
              document_type: "Policy paper",
            },
            {
              title: featured_edition_3.title,
              href: featured_edition_3.base_path,
              image: { url: "#{Plek.asset_root}/media/asset_manager_id_original/minister-of-funk.960x640.jpg",
                       medium_resolution_url: "#{Plek.asset_root}/media/asset_manager_id_s465/s465_minister-of-funk.960x640.jpg",
                       high_resolution_url: "#{Plek.asset_root}/media/asset_manager_id_s712/s712_minister-of-funk.960x640.jpg",
                       alt_text: "" },
              summary: govspeak_to_html(featured_edition_3.summary),
              public_updated_at: featured_edition_3.public_timestamp,
              document_type: "Generic edition",
            },
          ],
        }

        assert_equal expected_result, result
      end

      test "it returns an empty array if there are no features" do
        ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
          "settings" => {
            "features_enabled" => true,
          },
        }))

        featuring_edition = create(:published_standard_edition)
        create(:feature_list, featurable: featuring_edition, features: [])

        result = Features.for(featuring_edition)
        expected_result = {
          ordered_featured_documents: [],
        }

        assert_equal expected_result, result
      end
    end
  end
end
