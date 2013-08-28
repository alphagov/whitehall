require "test_helper"

class HtmlVersionsControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller

  test "#show displays the HTML version of the publication" do
    publication = create(:published_publication)

    get :show, publication_id: publication.document, id: publication.html_version.slug

    assert_response :success
    assert_equal publication, assigns(:document)
    assert_equal publication.html_version, assigns(:html_version)
  end

  test "#show displays the published edition of the version" do
    publication = create(:published_publication)
    draft = publication.create_draft(create(:user))

    get :show, publication_id: publication.document, id: publication.html_version.slug
    assert_response :success
    assert_equal publication, assigns(:edition)
  end

  test "#show 404s if the slug is wrong" do
    publication = create(:published_publication)
    get :show, publication_id: publication.document, id: 'not-the-real-slug'
    assert_response :not_found
  end

  test "#show 404s if no HTML version" do
    publication = create(:published_publication)
    get :show, publication_id: publication.document, id: 'slug'
    assert_response :not_found
  end

  test "#show 404s if the publication hasn't been published yet" do
    publication = create(:draft_publication)
    get :show, publication_id: publication.document, id: 'slug'
    assert_response :not_found
  end

  test "finds consultations if the html version is for a consultation" do
    consultation = create(:published_consultation, :with_html_version)

    get :show, consultation_id: consultation.document, id: consultation.html_version.slug

    assert_response :success
    assert_equal consultation, assigns(:document)
    assert_equal consultation.html_version, assigns(:html_version)
  end
end
