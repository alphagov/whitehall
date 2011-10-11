require "test_helper"

class OrganisationsControllerTest < ActionController::TestCase
  test "shows organisation title" do
    organisation = create(:organisation)
    get :show, id: organisation.to_param
    assert_select ".organisation .name", text: organisation.name
  end

  test "shows only published policies associated with organisation" do
    published_document = create(:published_policy)
    draft_document = create(:draft_policy)
    organisation = create(:organisation, documents: [published_document, draft_document])
    get :show, id: organisation.to_param
    assert_select_object(published_document)
    assert_select_object(draft_document, count: 0)
  end

  test "shows only published publications associated with organisation" do
    published_document = create(:published_publication)
    draft_document = create(:draft_publication)
    organisation = create(:organisation, documents: [published_document, draft_document])
    get :show, id: organisation.to_param
    assert_select_object(published_document)
    assert_select_object(draft_document, count: 0)
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
    first_minister = create(:ministerial_role)
    second_minister = create(:ministerial_role)
    organisation = create(:organisation, ministerial_roles: [first_minister, second_minister])
    minister_in_another_organisation = create(:ministerial_role)

    get :show, id: organisation.to_param

    assert_select_object(first_minister)
    assert_select_object(second_minister)
    assert_select_object(minister_in_another_organisation, count: 0)
  end

  test "shows minister role even if it is not currently fulfilled by any person" do
    minister = create(:ministerial_role, person: nil)
    organisation = create(:organisation, ministerial_roles: [minister])

    get :show, id: organisation.to_param

    assert_select_object(minister)
  end

  test "should not display an empty ministers section" do
    organisation = create(:organisation)
    get :show, id: organisation.to_param
    assert_select "#ministers", count: 0
  end

  test "should display a list of organisations" do
    organisation_1 = create(:organisation)
    organisation_2 = create(:organisation)

    get :index

    assert_select_object(organisation_1)
    assert_select_object(organisation_2)
  end

end