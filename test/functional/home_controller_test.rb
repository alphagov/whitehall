require "test_helper"

class HomeControllerTest < ActionController::TestCase
  include ActionDispatch::Routing::UrlFor
  include PublicDocumentRoutesHelper
  default_url_options[:host] = 'test.host'

  should_be_a_public_facing_controller

  test 'Atom feed has the right elements' do
    create_published_documents

    get :show, format: :atom

    assert_select_atom_feed do
      assert_select 'feed > id', 1
      assert_select 'feed > title', 1
      assert_select 'feed > author, feed > entry > author'
      assert_select 'feed > updated', 1
      assert_select 'feed > link[rel=?][type=?][href=?]', 'self', 'application/atom+xml', atom_feed_url(format: :atom), 1
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

  test "sunset homepage points search to main site search" do
    get :sunset

    assert_equal "/search", response.headers["X-Slimmer-Search-Path"]
  end

  private

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
