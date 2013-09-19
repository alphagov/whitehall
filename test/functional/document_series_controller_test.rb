require "test_helper"

class DocumentSeriesControllerTest < ActionController::TestCase
  def create_group_from_editions(series, heading, *editions)
    series.groups.create(heading: heading, body: 'Group body').tap do |group|
      group.documents = editions.map(&:document)
    end
  end

  should_be_a_public_facing_controller

  view_test 'GET #show displays the document series name and description, and sets the correct meta-description' do
    series = create(:published_document_series, title: "Some title", body: 'Description', summary: 'Some summary text')

    govspeak_transformation_fixture 'Description' => 'description-in-html' do
      get :show, id: series.slug
    end

    response_html = Nokogiri::HTML.parse(response.body)

    assert_select 'h1', "Some title"
    assert_select '.description', 'description-in-html'
    assert_equal 'Some summary text', response_html.at('meta[name=description]')[:content]
  end

  view_test "GET #show only displays groups containing published documents" do
    series = create(:published_document_series)

    published = create(:published_publication)
    shown = create_group_from_editions(series, 'Shown', published)

    draft = create(:draft_publication)
    not_shown = create_group_from_editions(series, 'Not shown', draft)

    get :show, id: series.slug

    assert_select 'h2', shown.heading
    assert_select '.group-body p', shown.body
    assert_select_object(published)

    refute_select 'h2', text: not_shown.heading
  end

  view_test "GET #show includes contents linking to groups" do
    series = create(:published_document_series, body: 'Description', summary: 'Summary')
    group_1 = create_group_from_editions(series, 'Group 1', create(:published_publication))
    group_2 = create_group_from_editions(series, 'Group 2', create(:published_publication))
    get :show, id: series.slug

    assert_select "ol li a[href=#group_#{group_1.id}]", text: 'Group 1'
    assert_select "ol li a[href=#group_#{group_2.id}]", text: 'Group 2'
  end

  test "GET #show sets Cache-Control: max-age to the time of the next scheduled publication in the series" do
    user = login_as(:departmental_editor)
    series = create(:published_document_series, :with_group)
    publication = create(:draft_publication, scheduled_publication: Time.zone.now + Whitehall.default_cache_max_age * 2)
    publication.reload.schedule_as(user, force: true)
    series.groups.first.documents << publication.document

    Timecop.freeze(Time.zone.now + Whitehall.default_cache_max_age * 1.5) do
      get :show, id: series.slug
    end

    assert_cache_control("max-age=#{Whitehall.default_cache_max_age/2}")
  end

  test "GET #show assigns @document_series as the DocumentSeries wrapped in a DocumentSeriesPresenter" do
    series = create(:published_document_series)
    get :show, id: series.slug

    assert assigns(:document_series).is_a? DocumentSeriesPresenter
    assert_equal series, assigns(:document_series).send(:document_series)
  end
end

class DocumentSeriesControllerRedirectsTest < ActionDispatch::IntegrationTest
  test "old route (eg. /government/organisations/?/series/?) should redirect to this show action" do
    get '/government/organisations/ministry-of-defence/series/firing-notice'

    assert response.redirect?
    assert response.location = document_series_url(id: 'firing-notice')
  end
end
