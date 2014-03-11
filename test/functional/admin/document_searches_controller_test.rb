require 'test_helper'

class Admin::DocumentSearchesControllerTest < ActionController::TestCase
  should_be_an_admin_controller

  setup do
    login_as create(:policy_writer)
  end

  def json_response
    JSON.parse(response.body)
  end

  view_test 'GET #show returns filter results as JSON' do
    publication = create(:publication, title: 'search term')
    get :show, title: 'search term', format: :json
    assert_response :success
    assert_equal true, json_response['results_any?']
    assert_equal 1, json_response['results'].size

    publication_json = json_response['results'].first
    assert_equal publication.id, publication_json['id']
    assert_equal publication.document_id, publication_json['document_id']
    assert_equal publication.title, publication_json['title']
    assert_equal 'publication', publication_json['type']
    assert_equal publication.display_type, publication_json['display_type']
  end

  view_test 'GET #show can filter by edition type and subtype' do
    guidance = create(:publication, title: 'search term', publication_type: PublicationType::Guidance)
    form = create(:publication, title: 'search term', publication_type: PublicationType::Form)

    get :show, title: 'search term', type: 'publication', subtypes: [PublicationType::Guidance.id], format: :json

    assert_response :success
    assert_equal true, json_response['results_any?']
    assert_equal 1, json_response['results'].size

    publication_json = json_response['results'].first
    assert_equal guidance.id, publication_json['id']
    assert_equal guidance.document_id, publication_json['document_id']
    assert_equal guidance.title, publication_json['title']
    assert_equal 'publication', publication_json['type']
    assert_equal guidance.display_type, publication_json['display_type']
  end
end
