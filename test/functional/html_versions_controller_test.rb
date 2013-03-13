require "test_helper"

class HtmlVersionsControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller

  test "#show displays the HTML version of the publication" do
    publication = create(:published_publication, :with_html_version)

    get :show, publication_id: publication.document, id: publication.html_version.slug

    assert_response :success
    assert_equal publication, assigns(:document)
    assert_equal publication.html_version, assigns(:html_version)
  end

  test "#show displays the published edition of the version" do
    publication = create(:published_publication, :with_html_version)
    draft = publication.create_draft(create(:user))

    get :show, publication_id: publication.document, id: publication.html_version.slug
    assert_response :success
    assert_equal publication, assigns(:publication)
  end

  test "#show 404s if the slug is wrong" do
    publication = create(:published_publication, :with_html_version)
    get :show, publication_id: publication.document, id: 'not-the-real-slug'
    assert_response :not_found
  end

  test "#show 404s if no HTML version" do
    publication = create(:published_publication)
    get :show, publication_id: publication.document, id: 'slug'
    assert_response :not_found
  end

  test "#show 404s if the publication hasn't been published yet" do
    publication = create(:draft_publication, :with_html_version)
    get :show, publication_id: publication.document, id: 'slug'
    assert_response :not_found
  end
end
