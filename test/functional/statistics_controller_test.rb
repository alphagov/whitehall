require "test_helper"
require "gds_api/test_helpers/content_store"

class StatisticsControllerTest < ActionController::TestCase
  include GdsApi::TestHelpers::ContentStore
  include TaxonomyHelper

  with_not_quite_as_fake_search
  should_be_a_public_facing_controller
  should_paginate :statistics, timestamp_key: :first_published_at
  should_return_json_suitable_for_the_document_filter :statistics

  def assert_publication_order(expected_order)
    actual_order = assigns(:publications).map(&:model).map(&:id)
    assert_equal expected_order.map(&:id), actual_order
  end

  setup do
    @content_item = content_item_for_base_path(
      '/government/statistics'
    )

    content_store_has_item(@content_item['base_path'], @content_item)

    stub_taxonomy_with_all_taxons
    @rummager = stub
  end

  view_test "#index only displays *published* statistics" do
    Sidekiq::Testing.inline! do
      superseded_statistics = create(:superseded_publication, :statistics)
      published_statistics = create(:published_statistics)
      draft_statistics = create(:draft_statistics)
      get :index

      assert_select_object(published_statistics)
      refute_select_object(superseded_statistics)
      refute_select_object(draft_statistics)
    end
  end

  test "#index sets Cache-Control: max-age to the time of the next scheduled publication" do
    login_as(:departmental_editor)
    create(:scheduled_publication, :statistics, scheduled_publication: Time.zone.now + Whitehall.default_cache_max_age * 2)

    Timecop.freeze(Time.zone.now + Whitehall.default_cache_max_age * 1.5) do
      get :index
    end

    assert_cache_control("max-age=#{Whitehall.default_cache_max_age / 2}")
  end

  view_test "#index highlights selected organisation filter options" do
    given_two_statistics_publications_in_two_organisations

    get :index, params: { departments: [@organisation_1, @organisation_2] }

    assert_select "select#departments[name='departments[]']" do
      assert_select "option[selected]", text: @organisation_1.name
      assert_select "option[selected]", text: @organisation_2.name
    end
  end

  view_test "#index highlights selected taxon filter options" do
    get :index, params: { taxons: [root_taxon['content_id']] }

    assert_select "select#taxons[name='taxons[]']" do
      assert_select "option[selected='selected']", text: root_taxon['title']
    end
  end

  view_test "#index highlights all taxons filter options by default" do
    get :index

    assert_select "select[name='taxons[]']" do
      assert_select "option[selected='selected']", text: "All topics"
    end
  end

  def given_two_statistics_publications_in_two_organisations
    @organisation_1, @organisation_2 = 2.times.map { create(:organisation, type: OrganisationType.ministerial_department) }
    create(:published_statistics, organisations: [@organisation_1])
    create(:published_national_statistics, organisations: [@organisation_2])
  end

  view_test "#index displays filter keywords" do
    get :index, params: { keywords: "olympics 2012" }

    assert_select "input[name='keywords'][value=?]", "olympics 2012"
  end

  view_test "#index displays date filter" do
    get :index, params: { from_date: "01/01/2011", to_date: "01/02/2012" }

    assert_select "input#from_date[name='from_date'][value='01/01/2011']"
    assert_select "input#to_date[name='to_date'][value='01/02/2012']"
  end

  view_test "#index orders statistics by publication date by default" do
    Sidekiq::Testing.inline! do
      statistics = 5.times.map { |i| create(:published_statistics, first_published_at: (10 - i).days.ago) }

      get :index

      assert_equal "publication_#{statistics.last.id}", css_select(".filter-results .document-row").first['id']
      assert_equal "publication_#{statistics.first.id}", css_select(".filter-results .document-row").last['id']
    end
  end

  view_test "#index should show a helpful message if there are no matching statistics" do
    get :index

    assert_select "h2", text: "There are no matching documents."
  end

  view_test "#index only lists statistics in the given locale" do
    english_publication = create(:published_statistics)
    french_publication = create(:published_statistics, translated_into: [:fr])
    get :index, params: { locale: 'fr' }

    assert_select "#publication_#{french_publication.id}"
    refute_select "#publication_#{english_publication.id}"
  end

  view_test '#index for non-english locales does not allow any filtering' do
    get :index, params: { locale: 'fr' }

    refute_select '.filter'
  end

  view_test '#index for non-english locales skips results summary' do
    get :index, params: { locale: 'fr' }
    refute_select '.filter-results-summary'
  end

  view_test "#index requested as JSON includes data for statistics" do
    Sidekiq::Testing.inline! do
      organisation_1 = create(:organisation, name: "org-name")
      organisation_2 = create(:organisation, name: "other-org")
      statistics_publication = create(:published_statistics, title: "statistics-title",
                                                             organisations: [organisation_1, organisation_2],
                                                             first_published_at: Date.parse("2011-03-14"))

      get :index, format: :json

      results = ActiveSupport::JSON.decode(response.body)["results"]
      assert_equal 1, results.length
      json = results.first['result']
      assert_equal "statistics-title", json["title"]
      assert_equal statistics_publication.id, json["id"]
      assert_equal statistic_path(statistics_publication.document), json["url"]
      assert_equal "org-name and other-org", json["organisations"]
      assert_equal %{<time class="public_timestamp" datetime="2011-03-14T00:00:00+00:00">14 March 2011</time>}, json["display_date_microformat"]
      assert_equal "Official Statistics", json["display_type"]
    end
  end

  view_test '#index should show relevant document collection information' do
    Sidekiq::Testing.inline! do
      create(:departmental_editor)
      statistics = create(:draft_statistics)
      collection = create(:document_collection, :with_group)
      collection.groups.first.documents = [statistics.document]
      stub_publishing_api_registration_for([collection, statistics])

      Whitehall.edition_services.force_publisher(collection).perform!
      Whitehall.edition_services.force_publisher(statistics).perform!
      get :index

      assert_select_object(statistics) do
        assert_select ".document-collections a[href=?]", @controller.public_document_path(collection)
      end
    end
  end

  view_test '#index requested as JSON includes document collection information' do
    Sidekiq::Testing.inline! do
      create(:departmental_editor)
      statistics = create(:draft_statistics)
      collection = create(:document_collection, :with_group)
      collection.groups.first.documents = [statistics.document]
      stub_publishing_api_registration_for([collection, statistics])
      Whitehall.edition_services.force_publisher(collection).perform!
      Whitehall.edition_services.force_publisher(statistics).perform!

      get :index, format: :json

      json = ActiveSupport::JSON.decode(response.body)
      result = json['results'].first['result']

      path = @controller.public_document_path(collection)
      link = %{<a href="#{path}">#{collection.title}</a>}
      assert_equal %{Part of a collection: #{link}}, result['publication_collections']
    end
  end

  view_test "index generates an atom feed with entries for statistics matching the current filter" do
    Sidekiq::Testing.inline! do
      organisation_1 = create(:organisation, name: "org-name")
      organisation_2 = create(:organisation, name: "other-org")
      statistics_publication = create(:published_statistics, title: "statistics-title",
                                                             organisations: [organisation_1, organisation_2],
                                                             first_published_at: Date.parse("2011-03-14"))

      get :index, params: { departments: [organisation_1.to_param] }, format: :atom

      assert_select_atom_feed do
        assert_select_atom_entries([statistics_publication])
      end
    end
  end

  view_test 'index includes tracking details on all links' do
    Sidekiq::Testing.inline! do
      published_statistics = create(:published_statistics)

      get :index

      assert_select_object(published_statistics) do
        results_list = css_select('ol.document-list').first

        assert_equal(
          'track-click',
          results_list.attributes['data-module'].value,
          "Expected the document list to have the 'track-click' module"
        )

        statistics_link = css_select('li.document-row a').first

        assert_equal(
          'navStatisticLinkClicked',
          statistics_link.attributes['data-category'].value,
          "Expected the data category attribute to be 'navStatisticLinkClicked'"
        )

        assert_equal(
          '1',
          statistics_link.attributes['data-action'].value,
          "Expected the data action attribute to be the 1st position on the list"
        )

        assert_equal(
          @controller.public_document_path(published_statistics),
          statistics_link.attributes['data-label'].value,
          "Expected the data label attribute to be the link of the published statistic"
        )

        options = JSON.parse(statistics_link.attributes['data-options'].value)

        assert_equal(
          '1',
          options['dimension28'],
          "Expected the custom dimension 28 to have the total number of published statistics"
        )

        assert_equal(
          published_statistics.title,
          options['dimension29'],
          "Expected the custom dimension 29 to have the title of the published statistic"
        )
      end
    end
  end
end
