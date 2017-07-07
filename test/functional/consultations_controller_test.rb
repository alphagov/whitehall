require "test_helper"

class ConsultationsControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller

  test 'index redirects to the publications index filtering consultations, retaining any other filter params' do
    get :index, topics: ["a-topic-slug"], departments: ['an-org-slug']
    assert_redirected_to publications_path(publication_filter_option: Whitehall::PublicationFilterOption::Consultation.slug, topics: ["a-topic-slug"], departments: ['an-org-slug'])
  end
end
