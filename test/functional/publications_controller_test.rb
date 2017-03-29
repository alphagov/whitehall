# encoding: utf-8

require "test_helper"

class PublicationsControllerTest < ActionController::TestCase
  with_not_quite_as_fake_search
  should_return_json_suitable_for_the_document_filter :publication
  should_return_json_suitable_for_the_document_filter :consultation
  should_set_slimmer_analytics_headers_for :publication
  should_set_the_article_id_for_the_edition_for :publication
  should_not_show_share_links_for :publication

  def assert_publication_order(expected_order)
    actual_order = assigns(:publications).map(&:model).map(&:id)
    assert_equal expected_order.map(&:id), actual_order
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

  view_test "#index generates an atom feed entries for consultations matching the current filter" do
    org = create(:organisation, name: "org-name")
    other_org = create(:organisation, name: "other-org")
    document = create(:published_consultation, organisations: [org], opening_at: Date.parse('2001-12-12'))
    create(:published_consultation, organisations: [other_org])

    get :index, format: :atom, departments: [org.to_param]

    assert_select_atom_feed do
      assert_select_atom_entries([document])
    end
  end

  test '#index atom feed orders publications according to first_published_at (newest first)' do
    oldest = create(:published_publication, first_published_at: 5.days.ago, title: "oldest")
    newest = create(:published_publication, first_published_at: 1.days.ago, title: "newest")
    middle = create(:published_publication, first_published_at: 3.days.ago, title: "middle")

    get :index, format: :atom

    assert_publication_order [newest, middle, oldest]
  end

  test '#index atom feed orders consultations according to first_published_at (newest first)' do
    oldest = create(:published_consultation, first_published_at: 5.days.ago, title: "oldest")
    newest = create(:published_consultation, first_published_at: 1.days.ago, title: "newest")
    middle = create(:published_consultation, first_published_at: 3.days.ago, title: "middle")

    get :index, format: :atom

    assert_publication_order [newest, middle, oldest]
  end

  test '#index atom feed orders mixed publications and consultations according to first_published_at or opening_at (newest first)' do
    oldest = create(:published_publication,  first_published_at: 5.days.ago, title: "oldest")
    newest = create(:published_consultation, opening_at: 1.days.ago, title: "newest")
    middle = create(:published_publication,  first_published_at: 3.days.ago, title: "middle")

    get :index, format: :atom

    assert_publication_order [newest, middle, oldest]
  end

  view_test '#index atom feed should return a valid feed if there are no matching documents' do
    get :index, format: :atom

    assert_select_atom_feed do
      assert_select 'feed > updated', text: Time.zone.now.iso8601
      assert_select 'feed > entry', count: 0
    end
  end

  view_test '#index atom feed should include links to download attachments' do
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

  view_test '#index atom feed should render fractions' do
    publication = create(:published_publication, body: "My favourite fraction is [Fraction:1/4].")

    get :index, format: :atom

    assert_select_atom_feed do
      assert_select 'feed > entry' do
        assert_select "content" do |content|
          assert content[0].to_s.include?("1_4.png"), "publication body should render fractions"
          assert content[0].to_s.include?("alt=\"1/4\""), "publication body should render fraction alt text"
        end
      end
    end
  end

  view_test '#index requested as JSON includes document collection information' do
    editor = create(:departmental_editor)
    publication = create(:draft_publication)
    collection = create(:document_collection, :with_group)
    collection.groups.first.documents = [publication.document]
    stub_publishing_api_registration_for([collection, publication])
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
