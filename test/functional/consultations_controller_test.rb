require "test_helper"

class ConsultationsControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller

  test "index redirects to the publications index filtering consultations, retaining any other filter params" do
    get :index, params: { topics: %w[a-topic-slug], departments: %w[an-org-slug] }
    assert_redirected_to(
      "http://test.host/search/policy-papers-and-consultations?content_store_document_type%5B%5D=open_consultations&content_store_document_type%5B%5D=closed_consultations&level_one_taxon%5B%5D=a-topic-slug&organisations%5B%5D=an-org-slug",
    )
  end
end
