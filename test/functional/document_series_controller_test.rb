require "test_helper"

class DocumentSeriesControllerTest < ActionController::TestCase
  def create_group_from_editions(series, heading, *editions)
    series.groups.create(heading: heading, body: 'Group body').tap do |group|
      group.documents = editions.map(&:document)
    end
  end

  should_be_a_public_facing_controller

  test 'index should redirect to organisations publication' do
    organisation = create(:organisation)

    get :index, organisation_id: organisation

    assert_redirected_to publications_path(departments: [organisation])
  end

  view_test 'GET #show displays the document series name and description' do
    publication = create(:published_publication)
    series = create(:document_series, description: 'Description', summary: 'Summary')

    govspeak_transformation_fixture 'Description' => 'description-in-html' do
      get :show, organisation_id: series.organisation, id: series
    end

    assert_select 'h1', series.name
    assert_select '.description', 'description-in-html'
    assert_equal 'Summary', assigns(:meta_description)
  end

  view_test "GET #show only displays groups containing published documents" do
    series = create(:document_series)

    published = create(:published_publication)
    shown = create_group_from_editions(series, 'Shown', published)

    draft = create(:draft_publication)
    not_shown = create_group_from_editions(series, 'Not shown', draft)

    get :show, organisation_id: series.organisation, id: series

    assert_select 'h2', shown.heading
    assert_select '.group-body p', shown.body
    assert_select_object(published)

    refute_select 'h2', text: not_shown.heading
  end

  test "GET #show sets Cache-Control: max-age to the time of the next scheduled publication in the series" do
    user = login_as(:departmental_editor)
    organisation = create(:organisation)
    series = create(:document_series, :with_group, organisation: organisation)
    publication = create(:draft_publication, scheduled_publication: Time.zone.now + Whitehall.default_cache_max_age * 2)
    publication.reload.schedule_as(user, force: true)
    series.groups.first.documents << publication.document

    Timecop.freeze(Time.zone.now + Whitehall.default_cache_max_age * 1.5) do
      get :show, organisation_id: organisation, id: series
    end

    assert_cache_control("max-age=#{Whitehall.default_cache_max_age/2}")
  end
end
