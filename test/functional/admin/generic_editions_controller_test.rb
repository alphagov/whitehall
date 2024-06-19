require "test_helper"

class Admin::GenericEditionsControllerTest < ActionController::TestCase
  should_be_an_admin_controller

  setup do
    login_as :writer
  end

  test "POST :create redirects to document summary page when 'Save and go to document summary' button clicked" do
    params = attributes_for(:edition)
    assert_difference "GenericEdition.count" do
      post :create, params: { edition: params, save_and_continue: "Save and continue editing" }
    end

    expected_message = "Your document has been saved. You need to <a class=\"govuk-link\" href=\"/government/admin/editions/#{Edition.last.id}/tags/edit\">add topic tags</a> before you can publish this document."
    assert_equal expected_message, flash[:notice]
    assert_redirected_to @controller.admin_edition_path(GenericEdition.last)
  end

  test "PUT :update redirects to document summary page when 'Save and got to document summary' button clicked" do
    edition = create(:edition)
    put :update, params: { id: edition, edition: { title: "New title" }, save_and_continue: "Save and continue editing" }
    assert_redirected_to @controller.admin_edition_path(edition)
  end

  test "PUT :update shows generic save message when 'Save and got to document summary' button clicked and document has no tags" do
    edition = create(:edition)
    stub_publishing_api_has_links(
      {
        "content_id" => edition.content_id,
        "links" => {
          "organisations" => %w[569a9ee5-c195-4b7f-b9dc-edc17a09113f],
        },
        "version" => 1,
      },
    )
    put :update, params: { id: edition, edition: { title: "New title" }, save_and_continue: "Save and continue editing" }

    assert_not edition.has_been_tagged?

    expected_message = "Your document has been saved. You need to <a class=\"govuk-link\" href=\"/government/admin/editions/#{edition.id}/tags/edit\">add topic tags</a> before you can publish this document."
    assert_equal expected_message, flash[:notice]
  end

  test "PUT :update shows generic save message when 'Save' button clicked and document has no tags" do
    edition = create(:edition)
    stub_publishing_api_has_links(
      {
        "content_id" => edition.content_id,
        "links" => {
          "organisations" => %w[569a9ee5-c195-4b7f-b9dc-edc17a09113f],
        },
        "version" => 1,
      },
    )
    put :update, params: { id: edition, edition: { title: "New title" }, save: "Save" }

    assert_not edition.has_been_tagged?

    expected_message = "Your document has been saved"
    assert_equal expected_message, flash[:notice]
  end

  test "PUT :update shows add tag save message when 'Save and got to document summary' button clicked and document has tags" do
    edition = create(:edition)
    stub_publishing_api_has_links(
      {
        "content_id" => edition.content_id,
        "links" => {
          "organisations" => %w[569a9ee5-c195-4b7f-b9dc-edc17a09113f],
          "taxons" => %w[7754ae52-34aa-499e-a6dd-88f04633b8ab],
        },
        "version" => 1,
      },
    )

    put :update, params: { id: edition, edition: { title: "New title" }, save_and_continue: "Save and continue editing" }

    assert edition.has_been_tagged?

    expected_message = "Your document has been saved"
    assert_equal expected_message, flash[:notice]
  end

  view_test "GET :edit shows the similar slug warning as an error which links to the input when user has 'Preview design system' permission" do
    create(:edition, title: "title")
    edition_with_same_title = create(:edition, title: "title")

    get :edit, params: { id: edition_with_same_title }

    assert_select ".govuk-error-summary a", text: "Title has been used before on GOV.UK, although the page may no longer exist. Please use another title", href: "#edition_title"
  end

  view_test "GET :show renders preview link if publically visible and change note is present" do
    published_edition = create(:published_edition)
    draft_edition = create(:draft_edition, change_note: "Random update.", document: published_edition.document)
    stub_publishing_api_expanded_links_with_taxons(draft_edition.content_id, [])

    get :show, params: { id: draft_edition }
    assert_select ".govuk-link", text: "Preview on website (opens in new tab)", href: draft_edition.public_url(draft: true)
  end

  view_test "GET :show doesn't render preview link if publically visible, change note is blank and edition is a major version" do
    published_edition = create(:published_edition)
    draft_edition = create(:draft_edition, change_note: nil, minor_change: false, document: published_edition.document)
    stub_publishing_api_expanded_links_with_taxons(draft_edition.content_id, [])

    get :show, params: { id: draft_edition }

    assert_select ".govuk-link", text: "Preview on website (opens in new tab)", href: draft_edition.public_url(draft: true), count: 0
    assert_select ".govuk-inset-text", text: "To see the changes and share a document preview link, add a change note or mark the change type to minor."
  end
end
