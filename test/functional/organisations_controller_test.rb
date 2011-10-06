require "test_helper"

class OrganisationsControllerTest < ActionController::TestCase
  test "shows organisation title" do
    organisation = create(:organisation)
    get :show, id: organisation.to_param
    assert_select ".organisation .name", text: organisation.name
  end

  test "shows only published policies associated with organisation" do
    published_edition = create(:published_edition)
    draft_edition = create(:draft_edition)
    organisation = create(:organisation, editions: [published_edition, draft_edition])
    get :show, id: organisation.to_param
    assert_select_object(published_edition)
    assert_select_object(draft_edition, count: 0)
  end

  test "shows only published publications associated with organisation" do
    published_edition = create(:published_edition, document: build(:publication))
    draft_edition = create(:draft_edition, document: build(:publication))
    organisation = create(:organisation, editions: [published_edition, draft_edition])
    get :show, id: organisation.to_param
    assert_select_object(published_edition)
    assert_select_object(draft_edition, count: 0)
  end

  test "should not display an empty published policies section" do
    organisation = create(:organisation)
    get :show, id: organisation.to_param
    assert_select "#policies", count: 0
  end

  test "should not display an empty published publications section" do
    organisation = create(:organisation)
    get :show, id: organisation.to_param
    assert_select "#publications", count: 0
  end
end