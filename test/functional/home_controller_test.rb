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
      assert_select 'feed > updated', text: documents.map(&:timestamp_for_sorting).max.iso8601

      assert_select 'feed > entry' do |entries|
        entries.zip(recent_documents) do |entry, document|
          assert_select entry, 'entry > published', text: document.timestamp_for_sorting.iso8601
          assert_select entry, 'entry > updated', text: document.published_at.iso8601
          assert_select entry, 'entry > link[rel=?][type=?][href=?]', 'alternate', 'text/html', public_document_url(document)
          assert_select entry, 'entry > title', text: document.title
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

  test "progress bar does not show if you have suppressed it" do
    @request.cookies['inside-gov-joining'] = '1'
    org = create(:ministerial_department)

    get :home

    refute_select '.progress-bar'
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
    # need to have the ministerial type so we can select non-ministerial
    create(:ministerial_organisation_type)

    type = create(:non_ministerial_organisation_type)
    create(:organisation, govuk_status: 'live', organisation_type: type)

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
