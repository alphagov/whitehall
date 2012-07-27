require "test_helper"

class HomeControllerTest < ActionController::TestCase
  include ActionDispatch::Routing::UrlFor
  include PublicDocumentRoutesHelper
  default_url_options[:host] = 'test.host'

  should_be_a_public_facing_controller


  test "show shows a list of recently published documents" do
    create_published_documents
    draft_documents = create_draft_documents

    get :show

    documents = Edition.published.by_published_at
    recent_documents = documents[0...10]
    older_documents = documents[10..-1]

    recent_documents.each do |d|
      assert_select_object(d) do
        d.organisations.each do |org|
          assert_select_object(org)
        end
      end
    end
    older_documents.each { |d| refute_select_object(d) }
    draft_documents.each { |d| refute_select_object(d) }
  end

  test "show avoids n+1 queries" do
    5.times { create(:published_policy) }
    assert 5 > count_queries { get :show }
  end


  test "show shows only the lead (well, first) organisation responsible for each document" do
    lead_org = create(:organisation, name: "Department of Fun")
    other_org = create(:organisation, name: "Ministry of Unpleasantness")
    docment = create(:published_policy, organisations: [lead_org, other_org])

    get :show

    assert_select_object lead_org
    refute_select_object other_org
  end

  test "show distinguishes between published and updated documents" do
    first_edition = create(:published_policy)
    updated_edition = create(:published_policy, published_at: Time.zone.now, first_published_at: 1.day.ago)

    get :show

    assert_select_object first_edition do
      assert_select '.published_or_updated', text: /published/i
    end

    assert_select_object updated_edition do
      assert_select '.published_or_updated', text: /updated/i
    end
  end

  test "should include links to main pages within introductory text" do
    get :show

    assert_select ".introduction" do
      assert_select "a[href=?]", announcements_path
      assert_select "a[href=?]", topics_path
      assert_select "a[href=?]", publications_path
      assert_select "a[href=?]", consultations_path
      assert_select "a[href=?]", ministerial_roles_path
      assert_select "a[href=?]", organisations_path
      assert_select "a[href=?]", countries_path
    end
  end

  test 'index has Atom feed autodiscovery link' do
    get :show
    assert_select 'head > link[rel=?][type=?][href=?]', 'alternate', 'application/atom+xml', atom_feed_url
  end

  test 'Atom feed has the right elements' do
    create_published_documents

    get :show, format: :atom

    assert_select_atom_feed do
      assert_select 'feed > id', 1
      assert_select 'feed > title', 1
      assert_select 'feed > author, feed > entry > author'
      assert_select 'feed > updated', 1
      assert_select 'feed > link[rel=?][type=?][href=?]', 'self', 'application/atom+xml', atom_feed_url, 1
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

  test 'Atom feed shows a list of recently published documents' do
    create_published_documents
    draft_documents = create_draft_documents

    get :show, format: :atom

    documents = Edition.published.by_published_at
    recent_documents = documents[0...10]
    older_documents = documents[10..-1]

    assert_select_atom_feed do
      assert_select 'feed > updated', text: documents.map(&:published_at).max.iso8601

      assert_select 'feed > entry' do |entries|
        entries.zip(recent_documents) do |entry, document|
          assert_select entry, 'entry > published', text: document.first_published_at.iso8601
          assert_select entry, 'entry > updated', text: document.published_at.iso8601
          assert_select entry, 'entry > link[rel=?][type=?][href=?]', 'alternate', 'text/html', public_document_url(document)
          assert_select entry, 'entry > title', text: document.title
        end
      end
    end
  end

  test "should display a page describing a tour around the site" do
    get :tour

    assert_response :success
  end

  private

  def assert_select_atom_feed(&block)
    assert_select ':root > feed[xmlns="http://www.w3.org/2005/Atom"][xml:lang="en-GB"]', &block
  end

  def create_published_documents
    5.downto(1) do |x|
      create(:published_policy, published_at: x.days.ago)
      create(:published_news_article, published_at: x.days.ago)
      create(:published_speech, published_at: x.days.ago)
      create(:published_publication, published_at: x.days.ago)
      create(:published_consultation, published_at: x.days.ago)
    end
  end

  def create_draft_documents
    [
      create(:draft_policy),
      create(:draft_news_article),
      create(:draft_speech),
      create(:draft_consultation),
      create(:draft_publication)
    ]
  end
end
