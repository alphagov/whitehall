require 'test_helper'

class Admin::GenericEditionsController::SpeedTaggingTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  test "should redirect to the next document imported without changing state when 'Save and Next' is clicked" do
    first_document, second_document = *create_list(:edition, 2, :imported)
    Import.stubs(:source_of).returns(mock(document_imported_before: second_document))

    first_document_latest_edition = first_document.latest_edition
    put :update, id: first_document_latest_edition, speed_save_next: 1, edition: {
      title: "new-title",
      body: "new-body"
    }

    assert first_document_latest_edition.reload.imported?
    assert_redirected_to admin_edition_path(second_document.latest_edition)
  end

  test "re-renders the show page when there are errors during speed tagging update" do
    imported_edition = create(:edition, :imported, title: 'News article')
    put :update, id: imported_edition, speed_save: 'Save', edition: { title: '' }

    assert_response :success
    assert_template :show
    assert_equal 'News article', imported_edition.reload.title
  end
end
