# encoding: utf-8

require "test_helper"

class PublicationsControllerTest < ActionController::TestCase
  with_not_quite_as_fake_search
  should_be_a_public_facing_controller
  should_display_attachments_for :publication
  should_display_localised_attachments
  should_show_the_world_locations_associated_with :publication
  should_display_inline_images_for :publication
  should_show_inapplicable_nations :publication
  should_show_related_policies_for :publication
  should_be_previewable :publication
  should_paginate :publication, timestamp_key: :first_published_at
  should_paginate :consultation, timestamp_key: :opening_at
  should_return_json_suitable_for_the_document_filter :publication
  should_return_json_suitable_for_the_document_filter :consultation
  should_set_meta_description_for :publication
  should_set_slimmer_analytics_headers_for :publication
  should_set_the_article_id_for_the_edition_for :publication
  should_not_show_share_links_for :publication

  def assert_publication_order(expected_order)
    actual_order = assigns(:publications).map(&:model).map(&:id)
    assert_equal expected_order.map(&:id), actual_order
  end

  test '#show displays published publications' do
    published_publication = create(:published_publication)
    get :show, id: published_publication.document
    assert_response :success
  end

  view_test "renders the publication summary from plain text" do
    publication = create(:published_publication, summary: 'plain text & so on')
    get :show, id: publication.document

    assert_select ".document-page .summary", text: "plain text &amp; so on"
  end

  view_test "#show renders the publication body using govspeak" do
    publication = create(:published_publication, body: "body-in-govspeak")
    govspeak_transformation_fixture "body-in-govspeak" => "body-in-html" do
      get :show, id: publication.document
    end

    assert_select ".body", text: "body-in-html"
  end

  view_test "#show should not explicitly say that publication applies to the whole of the UK" do
    published_publication = create(:published_publication)

    get :show, id: published_publication.document

    refute_select inapplicable_nations_selector
  end

  view_test "#show should display publication metadata" do
    publication = create(:published_publication,
      first_published_at: Date.parse("1916-05-31"),
      publication_type_id: PublicationType::Form.id
    )

    get :show, id: publication.document

    assert_select ".type", text: /Form/
    assert_select ".change-notes .published-at", text: "31 May 1916"
  end

  def assert_featured(doc)
    assert_select "#{record_css_selector(doc)}.featured"
  end

  view_test "#show should display a National Statistic badge on the appropriate documents" do
    publication = create(:published_publication, publication_type_id: PublicationType::NationalStatistics.id)
    get :show, id: publication.document

    assert_match /National statistics/, response.body
  end

  view_test "#show not link policies to national statistics publications" do
    publication = create(:published_publication, publication_type_id: PublicationType::NationalStatistics.id, related_editions: [create(:published_policy)])
    get :show, id: publication.document

    refute_select ".policies"
  end

  view_test "#show not link policies to general statistics publications" do
    publication = create(:published_publication, publication_type_id: PublicationType::Statistics.id, related_editions: [create(:published_policy)])
    get :show, id: publication.document

    refute_select ".policies"
  end

  view_test "#show should show ministers linked to publications" do
    minister = create(:ministerial_role)
    publication = create(:published_publication, ministerial_roles: [minister])
    get :show, id: publication.document

    assert_select '.meta a', text: minister.name
  end

  view_test "#show not link ministers to national statistics publications" do
    minister = create(:ministerial_role)
    publication = create(:published_publication, publication_type_id: PublicationType::NationalStatistics.id, ministerial_roles: [minister])
    get :show, id: publication.document

    refute_select_object minister
  end

  view_test "#show not link ministers to general statistics publications" do
    minister = create(:ministerial_role)
    publication = create(:published_publication, publication_type_id: PublicationType::Statistics.id, ministerial_roles: [minister])
    get :show, id: publication.document

    refute_select_object minister
  end

  view_test "#index only displays *published* publications" do
    without_delay! do
      superseded_publication = create(:superseded_publication)
      published_publication = create(:published_publication)
      draft_publication = create(:draft_publication)
      get :index

      assert_select_object(published_publication)
      refute_select_object(superseded_publication)
      refute_select_object(draft_publication)
    end
  end

  view_test "#index only displays *published* consultations" do
    without_delay! do
      superseded_consultation = create(:superseded_consultation)
      published_consultation = create(:published_consultation)
      draft_consultation = create(:draft_consultation)
      get :index

      assert_select_object(published_consultation)
      refute_select_object(superseded_consultation)
      refute_select_object(draft_consultation)
    end
  end

  test "#index sets Cache-Control: max-age to the time of the next scheduled publication" do
    user = login_as(:departmental_editor)
    publication = create(:draft_publication, scheduled_publication: Time.zone.now + Whitehall.default_cache_max_age * 2)
    publication.perform_force_schedule

    Timecop.freeze(Time.zone.now + Whitehall.default_cache_max_age * 1.5) do
      get :index
    end

    assert_cache_control("max-age=#{Whitehall.default_cache_max_age/2}")
  end

  view_test "#index highlights selected world filter options" do
    @world_location_1, @world_location_2 = create(:world_location), create(:world_location)
    create(:published_publication, world_locations: [@world_location_1])
    create(:published_publication, world_locations: [@world_location_2])

    get :index, world_locations: [@world_location_1, @world_location_2]

    assert_select "select#world_locations[name='world_locations[]']" do
      assert_select "option[selected='selected']", text: @world_location_1.name
      assert_select "option[selected='selected']", text: @world_location_2.name
    end
  end

  view_test "#index highlights selected topic filter options" do
    given_two_documents_in_two_topics

    get :index, topics: [@topic_1, @topic_2]

    assert_select "select#topics[name='topics[]']" do
      assert_select "option[selected='selected']", text: @topic_1.name
      assert_select "option[selected='selected']", text: @topic_2.name
    end
  end

  view_test "#index highlights selected organisation filter options" do
    given_two_documents_in_two_organisations

    get :index, departments: [@organisation_1, @organisation_2]

    assert_select "select#departments[name='departments[]']" do
      assert_select "option[selected]", text: @organisation_1.name
      assert_select "option[selected]", text: @organisation_2.name
    end
  end

  view_test "#index shows selected publication_filter_option in the title " do
    get :index, publication_filter_option: 'consultations'

    assert_select 'h1 span', ': All consultations'
  end

  view_test "#index highlights selected publication type filter options" do
    get :index, publication_filter_option: "forms"

    assert_select "select[name='publication_filter_option']" do
      assert_select "option[selected='selected']", text: Whitehall::PublicationFilterOption::Form.label
    end
  end

  view_test "#index displays filter keywords" do
    get :index, keywords: "olympics 2012"

    assert_select "input[name='keywords'][value=?]", "olympics 2012"
  end

  view_test "#index displays date filter" do
    get :index, from_date: "01/01/2011", to_date: "01/02/2012"

    assert_select "input#from_date[name='from_date'][value=01/01/2011]"
    assert_select "input#to_date[name='to_date'][value=01/02/2012]"
  end

  view_test "#index orders publications by publication date by default" do
    without_delay! do
      publications = 5.times.map {|i| create(:published_publication, first_published_at: (10 - i).days.ago) }

      get :index

      assert_equal "publication_#{publications.last.id}", css_select(".filter-results .document-row").first['id']
      assert_equal "publication_#{publications.first.id}", css_select(".filter-results .document-row").last['id']
    end
  end

  view_test "#index orders consultations by first_published_at date by default" do
    without_delay! do
      consultations = 5.times.map {|i| create(:published_consultation, opening_at: (10 - i).days.ago) }

      get :index

      assert_equal "consultation_#{consultations.last.id}", css_select(".filter-results .document-row").first['id']
      assert_equal "consultation_#{consultations.first.id}", css_select(".filter-results .document-row").last['id']
    end
  end

  view_test "#index orders documents by appropriate timestamp by default" do
    without_delay! do
      documents = [
        consultation = create(:published_consultation, opening_at: 5.days.ago),
        publication = create(:published_publication, first_published_at: 4.days.ago)
      ]

      get :index

      assert_equal "publication_#{publication.id}", css_select(".filter-results .document-row").first['id']
      assert_equal "consultation_#{consultation.id}", css_select(".filter-results .document-row").last['id']
    end
  end

  view_test "#index highlights all topics filter option by default" do
    given_two_documents_in_two_topics

    get :index

    assert_select "select[name='topics[]']" do
      assert_select "option[selected='selected']", text: "All topics"
    end
  end

  view_test "#index highlights all organisations filter options by default" do
    given_two_documents_in_two_organisations

    get :index

    assert_select "select[name='departments[]']" do
      assert_select "option[selected='selected']", text: "All departments"
    end
  end

  view_test "#index shows filter keywords placeholder by default" do
    get :index

    assert_select "input[name='keywords'][placeholder=?]", "keywords"
  end

  view_test "#index does not select a date filter by default" do
    get :index

    assert_select "input[name='from_date'][placeholder=?]", "e.g. 01/01/2013"
    assert_select "input[name='to_date'][placeholder=?]", "e.g. 30/02/2013"
  end

  view_test "#index should show a helpful message if there are no matching publications" do
    get :index

    assert_select "h2", text: "There are no matching documents."
  end

  view_test "#index only lists publications in the given locale" do
    english_publication = create(:published_publication)
    french_publication = create(:published_publication, translated_into: [:fr])

    get :index, locale: 'fr'

    assert_select_object french_publication
    refute_select_object english_publication
  end

  view_test '#index for non-english locales only allows filtering by world location' do
    get :index, locale: 'fr'

    assert_select '.filter', count: 2
    assert_select '#location-filter'
    assert_select '#filter-submit'
  end

  view_test '#index for non-english locales skips results summary' do
    get :index, locale: 'fr'
    refute_select '.filter-results-summary'
  end

  view_test "#index requested as JSON includes data for publications" do
    without_delay! do
      org = create(:organisation, name: "org-name")
      org2 = create(:organisation, name: "other-org")
      publication = create(:published_publication, title: "publication-title",
                           organisations: [org, org2],
                           first_published_at: Date.parse("2012-03-14"),
                           publication_type: PublicationType::CorporateReport)

      get :index, format: :json

      results = ActiveSupport::JSON.decode(response.body)["results"]
      assert_equal 1, results.length
      json = results.first
      assert_equal "publication", json["type"]
      assert_equal "publication-title", json["title"]
      assert_equal publication.id, json["id"]
      assert_equal publication_path(publication.document), json["url"]
      assert_equal "org-name and other-org", json["organisations"]
      assert_equal %{<abbr class="public_timestamp" title="2012-03-14T00:00:00+00:00">14 March 2012</abbr>}, json["display_date_microformat"]
      assert_equal "Corporate report", json["display_type"]
    end
  end

  view_test "#index requested as JSON includes data for consultations" do
    without_delay! do
      org = create(:organisation, name: "org-name")
      org2 = create(:organisation, name: "other-org")
      consultation = create(:published_consultation, title: "consultation-title",
                           organisations: [org, org2],
                           opening_at: Time.zone.parse("2012-03-14"),
                           closing_at: Time.zone.parse("2012-03-15"))

      get :index, format: :json

      results = ActiveSupport::JSON.decode(response.body)["results"]
      assert_equal 1, results.length
      json = results.first
      assert_equal "consultation", json["type"]
      assert_equal "consultation-title", json["title"]
      assert_equal consultation.id, json["id"]
      assert_equal consultation_path(consultation.document), json["url"]
      assert_equal "org-name and other-org", json["organisations"]
      assert_equal %{<abbr class="public_timestamp" title="2012-03-14T00:00:00+00:00">14 March 2012</abbr>}, json["display_date_microformat"]
      assert_equal "Consultation", json["display_type"]
    end
  end

  view_test "#index requested as JSON includes URL to the atom feed including any filters" do
    create(:topic, name: "topic-1")
    create(:organisation, name: "organisation-1")

    get :index, format: :json, topics: ["topic-1"], departments: ["organisation-1"]

    json = ActiveSupport::JSON.decode(response.body)

    assert_equal json["atom_feed_url"], publications_url(format: "atom", topics: ["topic-1"], departments: ["organisation-1"], host: Whitehall.public_host, protocol: Whitehall.public_protocol)
  end

  view_test "#index requested as JSON includes atom feed URL without date parameters" do
    create(:topic, name: "topic-1")

    get :index, format: :json, from_date: "2012-01-01", topics: ["topic-1"]

    json = ActiveSupport::JSON.decode(response.body)

    assert_equal json["atom_feed_url"], publications_url(format: "atom", topics: ["topic-1"], host: Whitehall.public_host, protocol: Whitehall.public_protocol)
  end

  view_test "#index requested as JSON includes email signup path without date parameters" do
    get :index, format: :json, to_date: "2012-01-01"

    json = ActiveSupport::JSON.decode(response.body)

    atom_url = publications_url(format: "atom", host: Whitehall.public_host, protocol: Whitehall.public_protocol)

    assert_equal json["email_signup_url"], new_email_signups_path(email_signup: { feed: atom_url })
  end

  view_test "#index requested as JSON includes email signup path with organisation and topic parameters" do
    topic = create(:topic)
    organisation = create(:organisation)

    get :index, format: :json, from_date: "2012-01-01", topics: [topic.slug], departments: [organisation.slug]

    json = ActiveSupport::JSON.decode(response.body)
    atom_url = publications_url(format: "atom", topics: [topic.slug], departments: [organisation.slug], host: Whitehall.public_host, protocol: Whitehall.public_protocol)

    assert_equal json["email_signup_url"], new_email_signups_path(email_signup: { feed: atom_url })
  end

  view_test '#index has atom feed autodiscovery link' do
    get :index
    assert_select_autodiscovery_link publications_url(format: "atom", host: Whitehall.public_host, protocol: Whitehall.public_protocol)
  end

  view_test '#index atom feed autodiscovery link includes any present filters' do
    topic = create(:topic)
    organisation = create(:organisation)

    get :index, topics: [topic], departments: [organisation]

    assert_select_autodiscovery_link publications_url(format: "atom", topics: [topic], departments: [organisation], host: Whitehall.public_host, protocol: Whitehall.public_protocol)
  end

  view_test '#index atom feed autodiscovery link does not include date filter' do
    topic = create(:topic)

    get :index, topics: [topic], to_date: "2012-01-01"

    assert_select_autodiscovery_link publications_url(format: "atom", topics: [topic], host: Whitehall.public_host, protocol: Whitehall.public_protocol)
  end

  view_test '#index shows a link to the atom feed including any present filters' do
    topic = create(:topic)
    organisation = create(:organisation)

    get :index, topics: [topic], departments: [organisation]

    feed_url = ERB::Util.html_escape(publications_url(format: "atom", topics: [topic], departments: [organisation], host: Whitehall.public_host, protocol: Whitehall.public_protocol))
    assert_select "a.feed[href=?]", feed_url
  end

  view_test '#index shows a link to the atom feed without any date filters' do
    organisation = create(:organisation)

    get :index, from_date: "2012-01-01", departments: [organisation]

    feed_url = ERB::Util.html_escape(publications_url(format: "atom", departments: [organisation], host: Whitehall.public_host, protocol: Whitehall.public_protocol))
    assert_select "a.feed[href=?]", feed_url
  end

  view_test "#index generates an atom feed for the current filter" do
    org = create(:organisation, name: "org-name")

    get :index, format: :atom, departments: [org.to_param]

    assert_select_atom_feed do
      assert_select 'feed > id', 1
      assert_select 'feed > title', 1
      assert_select 'feed > author, feed > entry > author'
      assert_select 'feed > updated', 1
      assert_select 'feed > link[rel=?][type=?][href=?]', 'self', 'application/atom+xml',
                    publications_url(format: :atom, departments: [org.to_param]), 1
      assert_select 'feed > link[rel=?][type=?][href=?]', 'alternate', 'text/html', root_url, 1
    end
  end

  view_test "#index generates an atom feed entries for publications matching the current filter" do
    without_delay! do
      org = create(:organisation, name: "org-name")
      other_org = create(:organisation, name: "other-org")
      p1 = create(:published_publication, organisations: [org], first_published_at: 2.days.ago.to_date)
      c1 = create(:published_consultation, organisations: [org], opening_at: 1.day.ago)
      p2 = create(:published_publication, organisations: [other_org])

      get :index, format: :atom, departments: [org.to_param]

      assert_select_atom_feed do
        assert_select_atom_entries([c1, p1])
      end
    end
  end

  view_test "#index generates an atom feed entries for consultations matching the current filter" do
    without_delay! do
      org = create(:organisation, name: "org-name")
      other_org = create(:organisation, name: "other-org")
      document = create(:published_consultation, organisations: [org], opening_at: Date.parse('2001-12-12'))
      create(:published_consultation, organisations: [other_org])

      get :index, format: :atom, departments: [org.to_param]

      assert_select_atom_feed do
        assert_select_atom_entries([document])
      end
    end
  end

  test '#index atom feed orders publications according to first_published_at (newest first)' do
    without_delay! do
      oldest = create(:published_publication, first_published_at: 5.days.ago, title: "oldest")
      newest = create(:published_publication, first_published_at: 1.days.ago, title: "newest")
      middle = create(:published_publication, first_published_at: 3.days.ago, title: "middle")

      get :index, format: :atom

      assert_publication_order [ newest, middle, oldest ]
    end
  end

  test '#index atom feed orders consultations according to opening_at (newest first)' do
    without_delay! do
      oldest = create(:published_consultation, opening_at: 5.days.ago, title: "oldest")
      newest = create(:published_consultation, opening_at: 1.days.ago, title: "newest")
      middle = create(:published_consultation, opening_at: 3.days.ago, title: "middle")

      get :index, format: :atom

      assert_publication_order [ newest, middle, oldest ]
    end
  end

  test '#index atom feed orders mixed publications and consultations according to first_published_at or opening_at (newest first)' do
    without_delay! do
      oldest = create(:published_publication,  first_published_at: 5.days.ago, title: "oldest")
      newest = create(:published_consultation, opening_at: 1.days.ago, title: "newest")
      middle = create(:published_publication,  first_published_at: 3.days.ago, title: "middle")

      get :index, format: :atom

      assert_publication_order [ newest, middle, oldest ]
    end
  end

  view_test '#index atom feed should return a valid feed if there are no matching documents' do
    get :index, format: :atom

    assert_select_atom_feed do
      assert_select 'feed > updated', text: Time.zone.now.iso8601
      assert_select 'feed > entry', count: 0
    end
  end

  view_test '#index atom feed should include links to download attachments' do
    without_delay! do
      publication = create(:published_publication, :with_file_attachment, title: "publication-title",
                           body: "include the attachment:\n\n!@1")

      get :index, format: :atom

      assert_select_atom_feed do
        assert_select 'feed > entry' do
          assert_select "content" do |content|
            assert content[0].to_s.include?(publication.attachments.first.url), "escaped publication body should include link to attachment"
          end
        end
      end
    end
  end

  view_test '#index should show relevant document collection information' do
    without_delay! do
      editor = create(:departmental_editor)
      publication = create(:draft_publication)
      collection = create(:document_collection, :with_group)
      collection.groups.first.documents = [publication.document]
      stub_panopticon_registration(collection)
      stub_panopticon_registration(publication)
      Whitehall.edition_services.force_publisher(collection).perform!
      Whitehall.edition_services.force_publisher(publication).perform!
      get :index

      assert_select_object(publication) do
        assert_select ".document-collections a[href=?]", public_document_path(collection)
      end
    end
  end

  view_test '#index requested as JSON includes document collection information' do
    without_delay! do
      editor = create(:departmental_editor)
      publication = create(:draft_publication)
      collection = create(:document_collection, :with_group)
      collection.groups.first.documents = [publication.document]
      stub_panopticon_registration(collection)
      stub_panopticon_registration(publication)
      Whitehall.edition_services.force_publisher(collection).perform!
      Whitehall.edition_services.force_publisher(publication).perform!

      get :index, format: :json

      json = ActiveSupport::JSON.decode(response.body)
      result = json['results'].first

      path = public_document_path(collection)
      link = %Q{<a href="#{path}">#{collection.title}</a>}
      assert_equal %Q{Part of a collection: #{link}}, result['publication_collections']
    end
  end

  view_test "#show displays the ISBN of the attached document" do
    edition = publication_with_attachment(isbn: '0099532816')
    get :show, id: edition.document
    assert_select_object(edition.attachments.first) do
      assert_select ".isbn", "0099532816"
    end
  end

  view_test "#show displays the Unique Reference Number of the attached document" do
    edition = publication_with_attachment(unique_reference: 'unique-reference')
    get :show, id: edition.document
    assert_select_object(edition.attachments.first) do
      assert_select ".unique_reference", "unique-reference"
    end
  end

  view_test "#show displays the Command Paper number of the attached document" do
    edition = publication_with_attachment(command_paper_number: 'Cm. 1234')
    get :show, id: edition.document
    assert_select_object(edition.attachments.first) do
      assert_select ".command_paper_number", "Cm. 1234"
    end
  end

  view_test "#show links to the url that the attachment can be ordered from" do
    edition = publication_with_attachment(order_url: 'http://example.com/order-path')
    get :show, id: edition.document
    assert_select_object(edition.attachments.first) do
      assert_select ".order_url", /order a copy/i
    end
  end

  view_test "#show displays the price of the purchasable attachment" do
    edition = publication_with_attachment(price: "1.23", order_url: 'http://example.com')
    get :show, id: edition.document
    assert_select_object(edition.attachments.first) do
      assert_select ".price", text: "£1.23"
    end
  end

  view_test '#show displays House of Commons paper metadata' do
    edition = publication_with_attachment(hoc_paper_number: '1234-i',
                                          parliamentary_session: '2009-10')
    get :show, id: edition.document
    assert_select_object(edition.attachments.first) do
      assert_select '.house_of_commons_paper_number', text: 'HC 1234-i'
      assert_select '.parliamentary_session', text: '2009-10'
    end
  end

  view_test '#show indicates when a command paper is unnumbered' do
    edition = publication_with_attachment(unnumbered_command_paper: true)
    get :show, id: edition.document
    assert_select_object(edition.attachments.first) do
      assert_select '.unnumbered-paper', text: 'Unnumbered command paper'
    end
  end

  view_test '#show indicates when a House of Commons paper is unnumbered' do
    edition = publication_with_attachment(unnumbered_hoc_paper: true)
    get :show, id: edition.document
    assert_select_object(edition.attachments.first) do
      assert_select '.unnumbered-paper', text: 'Unnumbered act paper'
    end
  end

  view_test "should show links to other available translations of the edition" do
    edition = build(:draft_publication)
    with_locale(:es) do
      edition.assign_attributes(attributes_for(:draft_edition, title: 'spanish-title'))
    end
    edition.save!
    force_publish(edition)

    get :show, id: edition.document

    assert_select ".translation", text: "English"
    refute_select "a[href=?]", public_document_path(edition, locale: :en), text: 'English'
    assert_select "a[href=?]", public_document_path(edition, locale: :es), text: 'Español'
  end

  view_test "should not show any links to translations when the edition is only available in one language" do
    edition = create(:draft_publication)
    force_publish(edition)

    get :show, id: edition.document

    refute_select ".translations"
  end

  private

  def publication_with_attachment(params = {})
    type = params.delete(:type) { |key| :file }
    trait = "with_#{type}_attachment".to_sym
    create(:published_publication, trait, body: "!@1").tap do |publication|
      attachment = publication.attachments.first
      attachment.update_attributes(params)
    end
  end

  def given_two_documents_in_two_organisations
    @organisation_1, @organisation_2 = create(:organisation, type: OrganisationType.ministerial_department), create(:organisation, type: OrganisationType.ministerial_department)
    create(:published_publication, organisations: [@organisation_1])
    create(:published_consultation, organisations: [@organisation_2])
  end

  def given_two_documents_in_two_topics
    @topic_1, @topic_2 = create(:topic), create(:topic)
    policy_1 = create(:published_policy, topics: [@topic_1])
    create(:published_publication, related_editions: [policy_1])
    policy_2 = create(:published_policy, topics: [@topic_2])
    create(:published_consultation, related_editions: [policy_2])
  end

  def create_publications_in(*topics)
    topics.map do |topic|
      policy = create(:published_policy, topics: [topic])
      create(:published_publication, related_editions: [policy])
    end
  end

end
