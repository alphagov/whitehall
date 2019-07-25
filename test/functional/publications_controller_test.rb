# encoding: utf-8

require "test_helper"
require "gds_api/test_helpers/content_store"

class PublicationsControllerTest < ActionController::TestCase
  include GdsApi::TestHelpers::ContentStore
  include TaxonomyHelper

  with_not_quite_as_fake_search
  should_be_a_public_facing_controller
  should_return_json_suitable_for_the_document_filter :publication
  should_return_json_suitable_for_the_document_filter :consultation

  def assert_publication_order(expected_order)
    actual_order = assigns(:publications).map(&:model).map(&:id)
    assert_equal expected_order.map(&:id), actual_order
  end

  setup do
    @content_item = content_item_for_base_path('/government/publications')
    content_store_has_item(@content_item['base_path'], @content_item)
    stub_taxonomy_with_all_taxons
    @default_params = {
      keywords: "one two",
      taxons: %w[one],
      subtaxons: %w[two],
      departments: {
        '0': 'one',
        '1': 'two',
      },
      world_locations: %w[one two],
      from_date: '01/01/2014',
      to_date: '01/01/2014',
      topical_events: %w[one two]
    }
    @default_converted_params = {
      keywords: "one two",
      level_one_taxon: 'one',
      level_two_taxon: 'two',
      organisations: %w[one two],
      world_locations: %w[one two],
      public_timestamp: { from: '01/01/2014', to: '01/01/2014' },
      topical_events: %w[one two],
    }
  end

  test "when locale is English redirect to a finder-frontend finder" do
    get :index
    assert_response :redirect
  end

  test "when locale is English it redirects with params for finder-frontend" do
    get :index, params: @default_params
    assert_redirected_to "#{Plek.new.website_root}/search/all?#{@default_converted_params.to_query}"
  end

  test "when locale is English it redirects an atom feed request with params for finder-frontend" do
    get :index, params: @default_params, format: :atom
    assert_redirected_to "#{Plek.new.website_root}/search/all.atom?#{@default_converted_params.to_query}"
  end

  test "when official_document_status is specified redirects with params for official-documents finder" do
    get :index, params: @default_params.merge(official_document_status: "command_and_act_papers")
    assert_redirected_to "#{Plek.new.website_root}/official-documents?#{@default_converted_params.to_query}"
  end

  test "strips out 'all' taxons from query string in redirect" do
    get :index, params: @default_params.merge(taxons: %w[all])
    assert_redirected_to "#{Plek.new.website_root}/search/all?#{@default_converted_params.merge(level_one_taxon: nil).compact.to_query}"
  end

  test "strips out 'all' subtaxons from query string in redirect" do
    get :index, params: @default_params.merge(subtaxons: %w[all])
    assert_redirected_to "#{Plek.new.website_root}/search/all?#{@default_converted_params.merge(level_two_taxon: nil).compact.to_query}"
  end

  test "strips out 'all' departments from query string in redirect" do
    get :index, params: @default_params.merge(departments: %w[all])
    assert_redirected_to "#{Plek.new.website_root}/search/all?#{@default_converted_params.merge(organisations: nil).compact.to_query}"
  end

  test "strips out 'all' people from query string in redirect" do
    get :index, params: @default_params.merge(people: %w[all])
    assert_redirected_to "#{Plek.new.website_root}/search/all?#{@default_converted_params.to_query}"
  end

  test "strips out 'all' world locations from query string in redirect" do
    get :index, params: @default_params.merge(world_locations: %w[all])
    assert_redirected_to "#{Plek.new.website_root}/search/all?#{@default_converted_params.merge(world_locations: nil).compact.to_query}"
  end

  view_test "#index only displays *published* publications" do
    Sidekiq::Testing.inline! do
      superseded_publication = create(:superseded_publication, translated_into: :fr)
      published_publication = create(:published_publication, translated_into: :fr)
      draft_publication = create(:draft_publication, translated_into: :fr)
      get :index, params: { locale: :fr }

      assert_select_object(published_publication)
      refute_select_object(superseded_publication)
      refute_select_object(draft_publication)
    end
  end

  view_test "#index only displays *published* consultations" do
    Sidekiq::Testing.inline! do
      superseded_consultation = create(:superseded_consultation, translated_into: :fr)
      published_consultation = create(:published_consultation, translated_into: :fr)
      draft_consultation = create(:draft_consultation, translated_into: :fr)
      get :index, params: { locale: :fr }

      assert_select_object(published_consultation)
      refute_select_object(superseded_consultation)
      refute_select_object(draft_consultation)
    end
  end

  view_test "#index highlights selected world filter options" do
    @world_location_1 = create(:world_location)
    @world_location_2 = create(:world_location)
    create(:published_publication, world_locations: [@world_location_1], translated_into: :fr)
    create(:published_publication, world_locations: [@world_location_2], translated_into: :fr)

    get :index, params: { world_locations: [@world_location_1, @world_location_2], locale: :fr }

    assert_select "select#world_locations[name='world_locations[]']" do
      assert_select "option[selected='selected']", text: @world_location_1.name
      assert_select "option[selected='selected']", text: @world_location_2.name
    end
  end

  view_test "#index orders publications by publication date by default" do
    Sidekiq::Testing.inline! do
      publications = 5.times.map { |i| create(:published_publication, first_published_at: (10 - i).days.ago, translated_into: :fr) }

      get :index, params: { locale: :fr }

      assert_equal "publication_#{publications.last.id}", css_select(".filter-results .document-row").first['id']
      assert_equal "publication_#{publications.first.id}", css_select(".filter-results .document-row").last['id']
    end
  end

  view_test "#index orders consultations by first_published_at date by default" do
    Sidekiq::Testing.inline! do
      consultations = 5.times.map { |i| create(:published_consultation, first_published_at: (10 - i).days.ago, translated_into: :fr) }

      get :index, params: { locale: :fr }

      assert_equal "consultation_#{consultations.last.id}", css_select(".filter-results .document-row").first['id']
      assert_equal "consultation_#{consultations.first.id}", css_select(".filter-results .document-row").last['id']
    end
  end

  view_test "#index orders documents by appropriate timestamp by default" do
    Sidekiq::Testing.inline! do
      consultation = create(:published_consultation, first_published_at: 5.days.ago, translated_into: :fr)
      publication = create(:published_publication, first_published_at: 4.days.ago, translated_into: :fr)

      get :index, params: { locale: :fr }

      assert_equal "publication_#{publication.id}", css_select(".filter-results .document-row").first['id']
      assert_equal "consultation_#{consultation.id}", css_select(".filter-results .document-row").last['id']
    end
  end

  view_test "#index should show a helpful message if there are no matching publications" do
    get :index, params: { locale: :fr }

    assert_select "h2", text: "Vous pouvez utiliser les filtres pour afficher uniquement les résultats qui correspondent à vos intérêts"
  end

  view_test "#index only lists publications in the given locale" do
    english_publication = create(:published_publication)
    french_publication = create(:published_publication, translated_into: [:fr])
    get :index, params: { locale: 'fr' }

    assert_select "#publication_#{french_publication.id}"
    refute_select "#publication_#{english_publication.id}"
  end

  view_test '#index for non-english locales only allows filtering by world location' do
    get :index, params: { locale: 'fr' }

    assert_select '.filter', count: 1
    assert_select '.filter #world_locations'
  end

  view_test '#index for non-english locales skips results summary' do
    get :index, params: { locale: 'fr' }
    refute_select '.filter-results-summary'
  end

  view_test "#index requested as JSON includes data for publications" do
    Sidekiq::Testing.inline! do
      org_1 = create(:organisation, name: "org-name")
      org_2 = create(:organisation, name: "other-org")
      publication = create(:published_publication, title: "publication-title",
                           organisations: [org_1, org_2],
                           first_published_at: Date.parse("2011-03-14"),
                           publication_type: PublicationType::CorporateReport)

      get :index, format: :json

      results = ActiveSupport::JSON.decode(response.body)["results"]
      assert_equal 1, results.length
      json = results.first['result']
      assert_equal "publication", json["type"]
      assert_equal "publication-title", json["title"]
      assert_equal publication.id, json["id"]
      assert_equal publication_path(publication.document), json["url"]
      assert_equal "org-name and other-org", json["organisations"]
      assert_equal %{<time class="public_timestamp" datetime="2011-03-14T00:00:00+00:00">14 March 2011</time>}, json["display_date_microformat"]
      assert_equal "Corporate report", json["display_type"]
    end
  end

  view_test "#index requested as JSON includes data for consultations" do
    Sidekiq::Testing.inline! do
      organisation_1 = create(:organisation, name: "org-name")
      organisation_2 = create(:organisation, name: "other-org")
      consultation = create(:published_consultation, title: "consultation-title",
                           organisations: [organisation_1, organisation_2],
                           opening_at: Time.zone.parse("2012-03-14"),
                           closing_at: Time.zone.parse("2012-03-15"),
                           first_published_at: Time.zone.parse("2011-03-10"))

      get :index, format: :json

      results = ActiveSupport::JSON.decode(response.body)["results"]
      assert_equal 1, results.length
      json = results.first['result']
      assert_equal "consultation", json["type"]
      assert_equal "consultation-title", json["title"]
      assert_equal consultation.id, json["id"]
      assert_equal consultation_path(consultation.document), json["url"]
      assert_equal "org-name and other-org", json["organisations"]
      assert_equal %{<time class="public_timestamp" datetime="2011-03-10T00:00:00+00:00">10 March 2011</time>}, json["display_date_microformat"]
      assert_equal "Consultation", json["display_type"]
    end
  end

  view_test "#index requested as JSON includes URL to the atom feed including any filters" do
    create(:organisation, name: "organisation-1")

    get :index, params: { taxons: %w[taxon-1], departments: %w[organisation-1] }, format: :json

    json = ActiveSupport::JSON.decode(response.body)

    assert_equal json["atom_feed_url"], publications_url(format: "atom", taxons: %w[taxon-1], departments: %w[organisation-1], host: Whitehall.public_host, protocol: Whitehall.public_protocol)
  end

  view_test "#index requested as JSON includes atom feed URL without date parameters" do
    get :index, params: { from_date: "2012-01-01", taxons: %w[taxon-1] }, format: :json

    json = ActiveSupport::JSON.decode(response.body)

    assert_equal json["atom_feed_url"], publications_url(format: "atom", taxons: %w[taxon-1], host: Whitehall.public_host, protocol: Whitehall.public_protocol)
  end

  view_test "#index requested as JSON includes email signup path without date parameters" do
    get :index, params: { to_date: "2012-01-01" }, format: :json

    json = ActiveSupport::JSON.decode(response.body)

    atom_url = publications_url(format: "atom", host: Whitehall.public_host, protocol: Whitehall.public_protocol)

    assert_equal json["email_signup_url"], new_email_signups_path(email_signup: { feed: atom_url })
  end

  view_test "#index requested as JSON includes email signup path with organisation and taxon parameters" do
    organisation = create(:organisation)

    get :index, params: { from_date: "2012-01-01", taxons: %w[taxon-1], departments: [organisation.slug] }, format: :json

    json = ActiveSupport::JSON.decode(response.body)
    atom_url = publications_url(format: "atom", taxons: %w[taxon-1], departments: [organisation.slug], host: Whitehall.public_host, protocol: Whitehall.public_protocol)

    assert_equal json["email_signup_url"], new_email_signups_path(email_signup: { feed: atom_url })
  end

  view_test '#index has atom feed autodiscovery link' do
    get :index, params: { locale: :fr }
    assert_select_autodiscovery_link publications_url(format: "atom", host: Whitehall.public_host, protocol: Whitehall.public_protocol)
  end

  view_test '#index atom feed autodiscovery link includes any present filters' do
    organisation = create(:organisation)

    get :index, params: { taxons: %w[taxon-1], departments: [organisation], locale: :fr }

    assert_select_autodiscovery_link publications_url(format: "atom", taxons: %w[taxon-1], departments: [organisation], host: Whitehall.public_host, protocol: Whitehall.public_protocol)
  end

  view_test '#index shows a link to the atom feed including any present filters' do
    organisation = create(:organisation)

    get :index, params: { taxons: %w[taxon-1], departments: [organisation], locale: :fr }

    feed_url = publications_url(format: "atom", taxons: %w[taxon-1], departments: [organisation], host: Whitehall.public_host, protocol: Whitehall.public_protocol)
    assert_select "a.feed[href=?]", feed_url
  end

  view_test '#index should show relevant document collection information' do
    Sidekiq::Testing.inline! do
      create(:departmental_editor)
      publication = create(:draft_publication, translated_into: :fr)
      collection = create(:document_collection, :with_group, translated_into: :fr)
      collection.groups.first.documents = [publication.document]
      stub_publishing_api_registration_for([collection, publication])
      Whitehall.edition_services.force_publisher(collection).perform!
      Whitehall.edition_services.force_publisher(publication).perform!
      get :index, params: { locale: :fr }

      assert_select_object(publication) do
        assert_select(
          ".document-collections a[href=?]",
          @controller.public_document_path(collection)
        )
      end
    end
  end

  view_test '#index requested as JSON includes document collection information' do
    Sidekiq::Testing.inline! do
      create(:departmental_editor)
      publication = create(:draft_publication)
      collection = create(:document_collection, :with_group)
      collection.groups.first.documents = [publication.document]
      stub_publishing_api_registration_for([collection, publication])
      Whitehall.edition_services.force_publisher(collection).perform!
      Whitehall.edition_services.force_publisher(publication).perform!

      get :index, format: :json

      json = ActiveSupport::JSON.decode(response.body)
      result = json['results'].first['result']

      path = @controller.public_document_path(collection)
      link = %{<a href="#{path}">#{collection.title}</a>}
      assert_equal %{Part of a collection: #{link}}, result['publication_collections']
    end
  end

private

  def publication_with_attachment(params = {})
    type = params.delete(:type) { |_key| :file }
    trait = "with_#{type}_attachment".to_sym
    create(:published_publication, trait, body: "!@1").tap do |publication|
      attachment = publication.attachments.first
      attachment.update(params)
    end
  end

  def given_two_documents_in_two_organisations
    @organisation_1 = create(:organisation, type: OrganisationType.ministerial_department)
    @organisation_2 = create(:organisation, type: OrganisationType.ministerial_department)
    create(:published_publication, organisations: [@organisation_1])
    create(:published_consultation, organisations: [@organisation_2])
  end

  view_test 'index includes tracking details on all links' do
    Sidekiq::Testing.inline! do
      published_publication = create(:published_publication, translated_into: :fr)

      get :index, params: { locale: :fr }

      assert_select_object(published_publication) do
        results_list = css_select('ol.document-list').first

        assert_equal(
          'track-click',
          results_list.attributes['data-module'].value,
          "Expected the document list to have the 'track-click' module"
        )

        publication_link = css_select('li.document-row a').first

        assert_equal(
          'navPublicationLinkClicked',
          publication_link.attributes['data-category'].value,
          "Expected the data category attribute to be 'navPublicationLinkClicked'"
        )

        assert_equal(
          '1',
          publication_link.attributes['data-action'].value,
          "Expected the data action attribute to be the 1st position on the list"
        )

        assert_equal(
          @controller.public_document_path(published_publication, locale: :fr),
          publication_link.attributes['data-label'].value,
          "Expected the data label attribute to be the link of the publication"
        )

        options = JSON.parse(publication_link.attributes['data-options'].value)

        assert_equal(
          '1',
          options['dimension28'],
          "Expected the custom dimension 28 to have the total number of publications"
        )

        assert_equal(
          "fr-#{published_publication.title}",
          options['dimension29'],
          "Expected the custom dimension 29 to have the title of the publication"
        )
      end
    end
  end
end
