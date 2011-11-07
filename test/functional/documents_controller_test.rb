require "test_helper"

class DocumentsControllerTest < ActionController::TestCase
  test "should only display published policies" do
    archived_policy = create(:archived_policy)
    published_policy = create(:published_policy)
    draft_policy = create(:draft_policy)
    get :index

    assert_select_object(published_policy)
    assert_select_object(archived_policy, count: 0)
    assert_select_object(draft_policy, count: 0)
  end

  test "should only display published consultations" do
    archived_consultation = create(:archived_consultation)
    published_consultation = create(:published_consultation)
    draft_consultation = create(:draft_consultation)

    get :index

    assert_select_object(published_consultation)
    assert_select_object(archived_consultation, count: 0)
    assert_select_object(draft_consultation, count: 0)
  end
end
