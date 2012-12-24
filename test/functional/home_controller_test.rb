require "test_helper"

class HomeControllerTest < ActionController::TestCase
  include ActionDispatch::Routing::UrlFor
  include PublicDocumentRoutesHelper
  default_url_options[:host] = 'test.host'

  should_be_a_public_facing_controller

  test 'Atom feed has the right elements' do
    create_published_documents

    get :feed, format: :atom

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
          assert_select entry, 'entry > summary', 1
          assert_select entry, 'entry > category', 1
          assert_select entry, 'entry > content[type=?]', 'html', 1
        end
      end
    end
  end

  test 'Atom feed shows a list of recently published documents' do
    create_published_documents
    draft_documents = create_draft_documents

    get :feed, format: :atom

    documents = Edition.published.in_reverse_chronological_order
    recent_documents = documents[0...10]
    older_documents = documents[10..-1]

    assert_select_atom_feed do
      assert_select 'feed > updated', text: recent_documents.first.timestamp_for_update.iso8601

      assert_select 'feed > entry' do |entries|
        entries.zip(recent_documents) do |entry, document|
          assert_select entry, 'entry > published', count: 1, text: document.timestamp_for_sorting.iso8601
          assert_select entry, 'entry > updated', count: 1, text: document.timestamp_for_update.iso8601
          assert_select entry, 'entry > link[rel=?][type=?][href=?]', 'alternate', 'text/html', public_document_url(document)
          assert_select entry, 'entry > title', count: 1, text: document.title
          assert_select entry, 'entry > summary', count: 1, text: document.summary
          assert_select entry, 'entry > category', count: 1, text: document.display_type
          assert_select entry, 'entry > content[type=?]', 'html', count: 1, text: /#{document.body}/
        end
      end
    end
  end

  test 'Atom feed shows a list of recently published documents with summary content and prefixe titles when requested' do
    create_published_documents
    draft_documents = create_draft_documents

    get :feed, format: :atom, govdelivery_version: 'yes'

    documents = Edition.published.in_reverse_chronological_order
    recent_documents = documents[0...10]
    older_documents = documents[10..-1]

    assert_select_atom_feed do
      assert_select 'feed > updated', text: recent_documents.first.timestamp_for_update.iso8601

      assert_select 'feed > entry' do |entries|
        entries.zip(recent_documents) do |entry, document|
          assert_select entry, 'entry > published', count: 1, text: document.timestamp_for_sorting.iso8601
          assert_select entry, 'entry > updated', count: 1, text: document.timestamp_for_update.iso8601
          assert_select entry, 'entry > link[rel=?][type=?][href=?]', 'alternate', 'text/html', public_document_url(document)
          assert_select entry, 'entry > title', count: 1, text: "#{document.display_type}: #{document.title}"
          assert_select entry, 'entry > summary', count: 1, text: document.summary
          assert_select entry, 'entry > category', count: 1, text: document.display_type
          assert_select entry, 'entry > content[type=?]', 'text', count: 1, text: document.summary
        end
      end
    end
  end

  test "home page doesn't link to itself in the progress bar" do
    get :home

    refute_select ".progress-bar a[href=#{root_path}]"
  end

  test "non home page doesn't link to itself in the progress bar" do
    get :how_government_works

    assert_select ".progress-bar a[href=#{root_path}]"
  end

  test "progress bar has current number of live departments" do
    org = create(:ministerial_department, govuk_status: 'live')
    org = create(:ministerial_department, govuk_status: 'transitioning')

    get :home

    assert_select '.progress-bar', /1 of 2/
  end

  test "how government works page shows a count of published policies" do
    create(:published_policy)
    create(:draft_policy)

    get :how_government_works

    assert_equal 1, assigns[:policy_count]
    assert_select ".policy-count .count", "1"
  end

  test "home page shows a count of live ministerial departmernts" do
    create(:ministerial_department, govuk_status: 'live')

    get :home

    assert_select '.live-ministerial-departments', '1'
  end

  test "home page shows a count of live non-ministerial departmernts" do
    # need to have the ministerial and suborg type so we can select non-ministerial
    create(:ministerial_organisation_type)
    create(:sub_organisation_type)

    type = create(:non_ministerial_organisation_type)
    org = create(:organisation, govuk_status: 'live', organisation_type: type)
    sub_org = create(:sub_organisation, govuk_status: 'live', parent_organisations: [create(:ministerial_department)])

    get :home

    assert_select '.live-other-departments', '1'
  end

  test "home page lists coming soon ministerial departments" do
    department = create(:ministerial_department, govuk_status: 'transitioning')

    get :home

    assert_select '.departments .coming-soon p', /#{department.name}/
  end

  test "home page lists coming soon non-ministerial departments" do
    create(:ministerial_organisation_type)
    create(:sub_organisation_type)

    type = create(:non_ministerial_organisation_type)
    department = create(:organisation, govuk_status: 'transitioning', organisation_type: type)

    get :home

    assert_select '.agencies .coming-soon p', /#{department.name}/
  end

  test "home page does not list transitioning sub-orgs" do
    create(:ministerial_organisation_type)
    create(:sub_organisation_type)

    department = create(:sub_organisation, govuk_status: 'transitioning')

    get :home

    refute_select '.agencies .coming-soon p', text: /#{department.name}/
  end

  test "home page lists topics with policies" do
    topics = [0, 1, 2].map { |n| create(:topic, published_policies_count: n) }

    get :home

    refute_select_object(topics[0])
    assert_select_object(topics[1])
    assert_select_object(topics[2])
  end

  private

  def create_published_documents
    5.downto(1) do |x|
      create(:published_policy, first_published_at: x.days.ago + 1.hour)
      create(:published_news_article, first_published_at: x.days.ago + 2.hours)
      create(:published_speech, delivered_on: x.days.ago + 3.hours)
      create(:published_publication, publication_date: x.days.ago + 4.hours)
      create(:published_consultation, opening_on: x.days.ago + 5.hours)
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
