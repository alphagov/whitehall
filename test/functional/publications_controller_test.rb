# encoding: utf-8

require "test_helper"

class PublicationsControllerTest < ActionController::TestCase
  include ActionDispatch::Routing::UrlFor
  include PublicDocumentRoutesHelper
  default_url_options[:host] = 'test.host'

  should_be_a_public_facing_controller
  should_display_attachments_for :publication
  should_show_the_countries_associated_with :publication
  should_display_inline_images_for :publication
  should_not_display_lead_image_for :publication
  should_show_change_notes :publication
  should_show_inapplicable_nations :publication
  should_be_previewable :publication
  should_paginate :publication
  should_return_json_suitable_for_the_document_filter :publication

  test 'show displays published publications' do
    published_publication = create(:published_publication)
    get :show, id: published_publication.document
    assert_response :success
  end

  test "renders the publication summary from plain text" do
    publication = create(:published_publication, summary: 'plain text & so on')
    get :show, id: publication.document

    assert_select ".extra-description", text: "plain text &amp; so on"
  end

  test "show renders the publication body using govspeak" do
    publication = create(:published_publication, body: "body-in-govspeak")
    govspeak_transformation_fixture "body-in-govspeak" => "body-in-html" do
      get :show, id: publication.document
    end

    assert_select ".body", text: "body-in-html"
  end

  test "show should not explicitly say that publication applies to the whole of the UK" do
    published_publication = create(:published_publication)

    get :show, id: published_publication.document

    refute_select inapplicable_nations_selector
  end

  test "show should display publication metadata" do
    publication = create(:published_publication,
      publication_date: Date.parse("1916-05-31"),
      publication_type_id: PublicationType::Form.id
    )

    get :show, id: publication.document

    assert_select "h1 .publication-type", text: /Form/
    assert_select ".change-notes .published-at", text: "31 May 1916"
  end

  def assert_featured(doc)
    assert_select "#{record_css_selector(doc)}.featured"
  end

  test "show should display a National Statistic badge on the appropriate documents" do
    publication = create(:published_publication, publication_type_id: PublicationType::NationalStatistics.id)
    get :show, id: publication.document

    assert_match /National Statistic/, response.body
  end

  test "index only displays *published* publications" do
    archived_publication = create(:archived_publication)
    published_publication = create(:published_publication)
    draft_publication = create(:draft_publication)
    get :index

    assert_select_object(published_publication)
    refute_select_object(archived_publication)
    refute_select_object(draft_publication)
  end

  test "index only displays *published* consultations" do
    archived_consultation = create(:archived_consultation)
    published_consultation = create(:published_consultation)
    draft_consultation = create(:draft_consultation)
    get :index

    assert_select_object(published_consultation)
    refute_select_object(archived_consultation)
    refute_select_object(draft_consultation)
  end

  test 'index should not use n+1 selects' do
    5.times { create(:published_publication) }
    5.times { create(:published_consultation) }
    assert 10 > count_queries { get :index }
  end

  test "index highlights selected topic filter options" do
    given_two_publications_in_two_topics

    get :index, topics: [@topic_1, @topic_2]

    assert_select "select[name='topics[]']" do
      assert_select "option[selected='selected']", text: @topic_1.name
      assert_select "option[selected='selected']", text: @topic_2.name
    end
  end

  test "index highlights selected organisation filter options" do
    given_two_publications_in_two_organisations

    get :index, departments: [@organisation_1, @organisation_2]

    assert_select "select[name='departments[]']" do
      assert_select "option[selected='selected']", text: @organisation_1.name
      assert_select "option[selected='selected']", text: @organisation_2.name
    end
  end

  test "index displays filter keywords" do
    get :index, keywords: "olympics 2012"

    assert_select "input[name='keywords'][value=?]", "olympics 2012"
  end

  test "index displays selected date filter" do
    get :index, direction: "before", date: "2010-01-01"

    assert_select "input#direction_before[name='direction'][checked=checked]"
    assert_select "select[name='date']" do
      assert_select "option[selected='selected'][value=?]", "2010-01-01"
    end
  end

  test "index orders publications by publication date by default" do
    publications = 5.times.map {|i| create(:published_publication, publication_date: (10 - i).days.ago) }

    get :index

    assert_equal "publication_#{publications.last.id}", css_select(".filter-results .document-row").first['id']
    assert_equal "publication_#{publications.first.id}", css_select(".filter-results .document-row").last['id']
  end

  test "index highlights all topics filter option by default" do
    given_two_publications_in_two_topics

    get :index

    assert_select "select[name='topics[]']" do
      assert_select "option[selected='selected']", text: "All topics"
    end
  end

  test "index highlights all organisations filter options by default" do
    given_two_publications_in_two_organisations

    get :index

    assert_select "select[name='departments[]']" do
      assert_select "option[selected='selected']", text: "All departments"
    end
  end

  test "index shows filter keywords placeholder by default" do
    get :index

    assert_select "input[name='keywords'][placeholder=?]", "keywords"
  end

  test "index does not select a date filter by default" do
    get :index

    assert_select "select[name='date']" do
      refute_select "option[selected='selected']"
    end
  end

  test "index should show a helpful message if there are no matching publications" do
    get :index

    assert_select "h2", text: "There are no matching publications."
  end

  test "index requested as JSON includes data for publications" do
    org = create(:organisation, name: "org-name")
    org2 = create(:organisation, name: "other-org")
    publication = create(:published_publication, title: "publication-title",
                         organisations: [org, org2],
                         publication_date: Date.parse("2012-03-14"),
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
    assert_equal "<abbr class=\"publication_date\" title=\"2012-03-14\">14 March 2012</abbr>", json["publication_date"]
    assert_equal "Corporate report", json["publication_type"]
  end

  test "index requested as JSON includes URL to the atom feed including any filters" do
    create(:topic, name: "topic-1")
    create(:organisation, name: "organisation-1")

    get :index, format: :json, topics: ["topic-1"], departments: ["organisation-1"]

    json = ActiveSupport::JSON.decode(response.body)

    assert_equal json["atom_feed_url"], publications_url(format: "atom", topics: ["topic-1"], departments: ["organisation-1"])
  end

  test "index requested as JSON includes atom feed URL without date parameters" do
    create(:topic, name: "topic-1")

    get :index, format: :json, date: "2012-01-01", direction: "before", topics: ["topic-1"]

    json = ActiveSupport::JSON.decode(response.body)

    assert_equal json["atom_feed_url"], publications_url(format: "atom", topics: ["topic-1"])
  end

  test 'index has atom feed autodiscovery link' do
    get :index
    assert_select_autodiscovery_link publications_url(format: "atom")
  end

  test 'index atom feed autodiscovery link includes any present filters' do
    topic = create(:topic)
    organisation = create(:organisation)

    get :index, topics: [topic], departments: [organisation]

    assert_select_autodiscovery_link publications_url(format: "atom", topics: [topic], departments: [organisation])
  end

  test 'index atom feed autodiscovery link does not include date filter' do
    topic = create(:topic)

    get :index, topics: [topic], date: "2012-01-01", direction: "after"

    assert_select_autodiscovery_link publications_url(format: "atom", topics: [topic])
  end

  test 'index shows a link to the atom feed including any present filters' do
    topic = create(:topic)
    organisation = create(:organisation)

    get :index, topics: [topic], departments: [organisation]

    feed_url = ERB::Util.html_escape(publications_url(format: "atom", topics: [topic], departments: [organisation]))
    assert_select "a.feed[href=?]", feed_url
  end

  test 'index shows a link to the atom feed without any date filters' do
    organisation = create(:organisation)

    get :index, date: "2012-01-01", direction: "before", departments: [organisation]

    feed_url = ERB::Util.html_escape(publications_url(format: "atom", departments: [organisation]))
    assert_select "a.feed[href=?]", feed_url
  end

  test "index can return an atom feed of documents matching the current filter" do
    org = create(:organisation, name: "org-name")
    other_org = create(:organisation, name: "other-org")
    publication = create(:published_publication, title: "publication-title",
                         organisations: [org],
                         publication_date: Date.parse("2012-03-14"),
                         publication_type: PublicationType::CorporateReport)
    other_publication = create(:published_publication, title: "publication-title",
                         organisations: [other_org],
                         publication_date: Date.parse("2012-03-14"),
                         publication_type: PublicationType::CorporateReport)


    get :index, format: :atom, departments: [org]

    assert_select_atom_feed do
      assert_select 'feed > id', 1
      assert_select 'feed > title', 1
      assert_select 'feed > author, feed > entry > author'
      assert_select 'feed > updated', 1
      assert_select 'feed > link[rel=?][type=?][href=?]', 'self', 'application/atom+xml',
                    publications_url(format: :atom, departments: [org]), 1
      assert_select 'feed > link[rel=?][type=?][href=?]', 'alternate', 'text/html', root_url, 1

      assert_select 'feed > entry' do |entries|
        entries.each do |entry|
          assert_select entry, 'entry > id', 1
          assert_select entry, 'entry > published', 1
          assert_select entry, 'entry > updated', 1
          assert_select entry, 'entry > link[rel=?][type=?]', 'alternate', 'text/html', 1
          assert_select entry, 'entry > title', 1
          assert_select entry, 'entry > content[type=?]', 'html', 1
        end
      end
    end
  end

  test 'index atom feed shows a list of recently published publications' do
    publication = create(:published_publication, title: "publication-title",
                         published_at: Time.zone.parse("2012-04-10 11:00"))
    other_publication = create(:published_publication, title: "publication-title",
                         published_at: Time.zone.parse("2012-03-14 09:00"))

    get :index, format: :atom

    assert_select_atom_feed do
      assert_select 'feed > updated', text: Time.zone.parse("2012-04-10 11:00").iso8601

      assert_select 'feed > entry' do |entries|
        entries.zip([publication, other_publication]).each do |entry, document|
          assert_select entry, 'entry > published', text: document.first_published_at.iso8601
          assert_select entry, 'entry > updated', text: document.published_at.iso8601
          assert_select entry, 'entry > link[rel=?][type=?][href=?]', 'alternate', 'text/html', public_document_url(document)
          assert_select entry, 'entry > title', text: document.title
        end
      end
    end
  end

  test 'index atom feed should return a valid feed if there are no matching documents' do
    get :index, format: :atom

    assert_select_atom_feed do
      assert_select 'feed > updated', text: Time.zone.now.iso8601
      assert_select 'feed > entry', count: 0
    end
  end

  test 'index atom feed should include links to download attachments' do
    publication = create(:published_publication, :with_attachment, title: "publication-title",
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

  test 'index should show relevant document series information' do
    organisation = create(:organisation)
    series = create(:document_series, organisation: organisation)
    publication = create(:published_publication, document_series: series)

    get :index

    assert_select_object(publication) do
      assert_select ".publication_series a[href=?]", organisation_document_series_path(organisation, series)
    end
  end

  test 'index requested as JSON includes document series information' do
    organisation = create(:organisation)
    series = create(:document_series, organisation: organisation)
    publication = create(:published_publication, document_series: series)

    get :index, format: :json

    json = ActiveSupport::JSON.decode(response.body)

    result = json['results'].first

    assert_equal "Part of a series: <a href=\"#{organisation_document_series_path(organisation, series)}\">#{series.name}</a>", result['publication_series']
  end

  test "show displays the ISBN of the attached document" do
    attachment = create(:attachment, isbn: '0099532816')
    edition = create("published_publication", :with_attachment, body: "!@1", attachments: [attachment])

    get :show, id: edition.document

    assert_select_object(attachment) do
      assert_select ".isbn", "0099532816"
    end
  end

  test "show doesn't display an empty ISBN if none exists for the attachment" do
    [nil, ""].each do |isbn|
      attachment = create(:attachment, isbn: isbn)
      edition = create("published_publication", :with_attachment, body: "!@1", attachments: [attachment])

      get :show, id: edition.document

      assert_select_object(attachment) do
        refute_select ".isbn"
      end
    end
  end

  test "show displays the Unique Reference Number of the attached document" do
    attachment = create(:attachment, unique_reference: 'unique-reference')
    edition = create("published_publication", :with_attachment, body: "!@1", attachments: [attachment])

    get :show, id: edition.document

    assert_select_object(attachment) do
      assert_select ".unique_reference", "unique-reference"
    end
  end

  test "show doesn't display an empty Unique Reference Number if none exists for the attachment" do
    [nil, ""].each do |unique_reference|
      attachment = create(:attachment, unique_reference: unique_reference)
      edition = create("published_publication", :with_attachment, body: "!@1", attachments: [attachment])

      get :show, id: edition.document

      assert_select_object(attachment) do
        refute_select ".unique_reference"
      end
    end
  end

  test "show displays the Command Paper number of the attached document" do
    attachment = create(:attachment, command_paper_number: 'Cm. 1234')
    edition = create("published_publication", :with_attachment, body: "!@1", attachments: [attachment])

    get :show, id: edition.document

    assert_select_object(attachment) do
      assert_select ".command_paper_number", "Cm. 1234"
    end
  end

  test "show doesn't display an empty Command Paper number if none exists for the attachment" do
    [nil, ""].each do |command_paper_number|
      attachment = create(:attachment, command_paper_number: command_paper_number)
      edition = create("published_publication", :with_attachment, body: "!@1", attachments: [attachment])

      get :show, id: edition.document

      assert_select_object(attachment) do
        refute_select ".command_paper_number"
      end
    end
  end

  test "show links to the url that the attachment can be ordered from" do
    attachment = create(:attachment, order_url: 'http://example.com/order-path')
    edition = create("published_publication", :with_attachment, body: "!@1", attachments: [attachment])

    get :show, id: edition.document

    assert_select_object(attachment) do
      assert_select ".order_url", /order a copy/i
    end
  end

  test "show doesn't display an empty order url if none exists for the attachment" do
    [nil, ""].each do |order_url|
      attachment = create(:attachment, order_url: order_url)
      edition = create("published_publication", :with_attachment, body: "!@1", attachments: [attachment])

      get :show, id: edition.document

      assert_select_object(attachment) do
        refute_select ".order_url"
      end
    end
  end

  test "show displays the price of the purchasable attachment" do
    attachment = create(:attachment, price: "1.23", order_url: 'http://example.com')
    edition = create("published_publication", :with_attachment, body: "!@1", attachments: [attachment])

    get :show, id: edition.document

    assert_select_object(attachment) do
      assert_select ".price", text: "£1.23"
    end
  end

  test "show doesn't display an empty price if none exists for the attachment" do
    [nil, ""].each do |price|
      attachment = create(:attachment, price_in_pence: price)
      edition = create("published_publication", :with_attachment, body: "!@1", attachments: [attachment])

      get :show, id: edition.document

      assert_select_object(attachment) do
        refute_select ".price"
      end
    end
  end

  test "should display links to related policies" do
    policy = create(:published_policy)
    publication = create(:published_publication, related_policies: [policy])

    get :show, id: publication.document

    assert_select_object(policy)
  end

  private

  def given_two_publications_in_two_organisations
    @organisation_1, @organisation_2 = create(:organisation), create(:organisation)
    @publication_in_organisation_1 = create(:published_publication, organisations: [@organisation_1])
    @publication_in_organisation_2 = create(:published_publication, organisations: [@organisation_2])
  end

  def given_two_publications_in_two_topics
    @topic_1, @topic_2 = create(:topic), create(:topic)
    @published_publication, @published_in_second_topic = create_publications_in(@topic_1, @topic_2)
  end

  def create_publications_in(*topics)
    topics.map do |topic|
      policy = create(:published_policy, topics: [topic])
      create(:published_publication, related_policies: [policy])
    end
  end

end
