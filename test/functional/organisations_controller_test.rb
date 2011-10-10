require "test_helper"

class OrganisationsControllerTest < ActionController::TestCase
  test "shows organisation title" do
    organisation = create(:organisation)
    get :show, id: organisation.to_param
    assert_select ".organisation .name", text: organisation.name
  end

  test "shows only published policies associated with organisation" do
    published_edition = create(:published_policy)
    draft_edition = create(:draft_policy)
    organisation = create(:organisation, editions: [published_edition, draft_edition])
    get :show, id: organisation.to_param
    assert_select_object(published_edition)
    assert_select_object(draft_edition, count: 0)
  end

  test "shows only published publications associated with organisation" do
    published_edition = create(:published_publication)
    draft_edition = create(:draft_publication)
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

  test "shows ministers associated with organisation" do
    first_minister = create(:role)
    second_minister = create(:role)
    organisation = create(:organisation, roles: [first_minister, second_minister])
    minister_in_another_organisation = create(:role)

    get :show, id: organisation.to_param

    assert_select_object(first_minister)
    assert_select_object(second_minister)
    assert_select_object(minister_in_another_organisation, count: 0)
  end

  test "shows minister role even if it is not currently fulfilled by any person" do
    minister = create(:role, person: nil)
    organisation = create(:organisation, roles: [minister])

    get :show, id: organisation.to_param

    assert_select_object(minister)
  end

  test "should not display an empty ministers section" do
    organisation = create(:organisation)
    get :show, id: organisation.to_param
    assert_select "#ministers", count: 0
  end

end