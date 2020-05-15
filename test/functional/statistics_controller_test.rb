require "test_helper"
require "gds_api/test_helpers/content_store"

class StatisticsControllerTest < ActionController::TestCase
  include GdsApi::TestHelpers::ContentStore
  include TaxonomyHelper

  with_not_quite_as_fake_search
  should_be_a_public_facing_controller
  should_redirect_json_in_english_locale

  def assert_publication_order(expected_order)
    actual_order = assigns(:publications).map(&:model).map(&:id)
    assert_equal expected_order.map(&:id), actual_order
  end

  setup do
    @content_item = content_item_for_base_path(
      "/government/statistics",
    )

    stub_content_store_has_item(@content_item["base_path"], @content_item)

    stub_taxonomy_with_all_taxons
    @rummager = stub
  end

  test "when locale is english it redirects to research and statistics" do
    get :index
    assert_response :redirect
  end

  test "when locale is english it redirects with params for finder-frontend" do
    get :index,
        params: {
          keywords: "one two",
          taxons: %w[one],
          departments: %w[all one two],
          from_date: "01/01/2014",
          to_date: "01/01/2014",
        }

    redirect_params_query = {
      content_store_document_type: "published_statistics",
      keywords: "one two",
      level_one_taxon: "one",
      organisations: %w[one two],
      public_timestamp: { from: "01/01/2014", to: "01/01/2014" },
    }.to_query

    assert_redirected_to "#{Plek.new.website_root}/search/research-and-statistics?#{redirect_params_query}"
  end

  view_test "#index only lists statistics in the given locale" do
    english_publication = create(:published_statistics)
    french_publication = create(:published_statistics, translated_into: [:fr])
    get :index, params: { locale: "fr" }

    assert_select "#publication_#{french_publication.id}"
    refute_select "#publication_#{english_publication.id}"
  end

  view_test "#index for non-english locales does not allow any filtering" do
    get :index, params: { locale: "fr" }

    refute_select ".filter"
  end

  view_test "#index for non-english locales skips results summary" do
    get :index, params: { locale: "fr" }
    refute_select ".filter-results-summary"
  end

  view_test "#index only displays *published* statistics" do
    Sidekiq::Testing.inline! do
      superseded_statistics = create(:superseded_publication, :statistics, translated_into: :fr)
      published_statistics = create(:published_statistics, translated_into: :fr)
      draft_statistics = create(:draft_statistics, translated_into: :fr)
      get :index, params: { locale: "fr" }

      assert_select_object(published_statistics)
      refute_select_object(superseded_statistics)
      refute_select_object(draft_statistics)
    end
  end

  view_test "#index orders statistics by publication date by default" do
    Sidekiq::Testing.inline! do
      statistics = 5.times.map { |i| create(:published_statistics, first_published_at: (10 - i).days.ago, translated_into: :fr) }

      get :index, params: { locale: "fr" }

      assert_equal "publication_#{statistics.last.id}", css_select(".filter-results .document-row").first["id"]
      assert_equal "publication_#{statistics.first.id}", css_select(".filter-results .document-row").last["id"]
    end
  end

  view_test "#index should show a helpful message if there are no matching statistics" do
    get :index, params: { locale: "fr" }

    assert_select "h2", text: "Vous pouvez utiliser les filtres pour afficher uniquement les résultats qui correspondent à vos intérêts"
  end

  view_test "#index requested as JSON includes data for statistics" do
    Sidekiq::Testing.inline! do
      organisation_1 = create(:organisation, name: "org-name")
      organisation_2 = create(:organisation, name: "other-org")
      statistics_publication = create(
        :published_statistics,
        title: "statistics-title",
        organisations: [organisation_1, organisation_2],
        first_published_at: Date.parse("2011-03-14"),
        translated_into: :fr,
      )

      get :index, format: :json, params: { locale: "fr" }

      results = ActiveSupport::JSON.decode(response.body)["results"]
      assert_equal 1, results.length
      json = results.first["result"]
      assert_equal "fr-statistics-title", json["title"]
      assert_equal statistics_publication.id, json["id"]
      assert_equal statistic_path(statistics_publication.document), json["url"]
      assert_equal "org-name et other-org", json["organisations"]
      assert_equal %(<time class="public_timestamp" datetime="2011-03-14T00:00:00+00:00">mars 14, 2011</time>), json["display_date_microformat"]
      assert_equal "Official Statistics", json["display_type"]
    end
  end

  view_test "#index should show relevant document collection information" do
    Sidekiq::Testing.inline! do
      create(:departmental_editor)
      statistics = create(:draft_statistics, translated_into: :fr)
      collection = create(:document_collection, :with_group, translated_into: :fr)
      collection.groups.first.documents = [statistics.document]
      stub_publishing_api_registration_for([collection, statistics])

      Whitehall.edition_services.force_publisher(collection).perform!
      Whitehall.edition_services.force_publisher(statistics).perform!
      get :index, params: { locale: :fr }

      assert_select_object(statistics) do
        assert_select ".document-collections a[href=?]", @controller.public_document_path(collection, locale: :fr)
      end
    end
  end

  view_test "#index requested as JSON includes document collection information" do
    Sidekiq::Testing.inline! do
      create(:departmental_editor)
      statistics = create(:draft_statistics, translated_into: :fr)
      collection = create(:document_collection, :with_group, translated_into: :fr)
      collection.groups.first.documents = [statistics.document]
      stub_publishing_api_registration_for([collection, statistics])
      Whitehall.edition_services.force_publisher(collection).perform!
      Whitehall.edition_services.force_publisher(statistics).perform!

      get :index, format: :json, params: { locale: "fr" }

      json = ActiveSupport::JSON.decode(response.body)
      result = json["results"].first["result"]

      path = @controller.public_document_path(collection)
      link = %(<a href="#{path}">fr-#{collection.title}</a>)
      assert_equal %(Part of a collection: #{link}), result["publication_collections"]
    end
  end

  view_test "index includes tracking details on all links" do
    Sidekiq::Testing.inline! do
      published_statistics = create(:published_statistics, translated_into: :fr)

      get :index, params: { locale: "fr" }

      assert_select_object(published_statistics) do
        results_list = css_select("ol.document-list").first

        assert_equal(
          "track-click",
          results_list.attributes["data-module"].value,
          "Expected the document list to have the 'track-click' module",
        )

        statistics_link = css_select("li.document-row a").first

        assert_equal(
          "navStatisticLinkClicked",
          statistics_link.attributes["data-category"].value,
          "Expected the data category attribute to be 'navStatisticLinkClicked'",
        )

        assert_equal(
          "1",
          statistics_link.attributes["data-action"].value,
          "Expected the data action attribute to be the 1st position on the list",
        )

        assert_equal(
          @controller.public_document_path(published_statistics, locale: :fr),
          statistics_link.attributes["data-label"].value,
          "Expected the data label attribute to be the link of the published statistic",
        )

        options = JSON.parse(statistics_link.attributes["data-options"].value)

        assert_equal(
          "1",
          options["dimension28"],
          "Expected the custom dimension 28 to have the total number of published statistics",
        )

        assert_equal(
          "fr-#{published_statistics.title}",
          options["dimension29"],
          "Expected the custom dimension 29 to have the title of the published statistic",
        )
      end
    end
  end
end
